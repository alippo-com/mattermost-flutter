
class ParsedCommand {
  ParseState state = ParseState.Start;
  String command;
  int i = 0;
  String incomplete = '';
  int incompleteStart = 0;
  AppBinding? binding;
  AppForm? resolvedForm;
  FormsCache formsCache;
  AppField? field;
  int position = 0;
  Map<String, dynamic> values = {};
  String location = '';
  String error = '';
  AppLocalizations intl;

  ParsedCommand(this.command, this.formsCache, this.intl);

  ParsedCommand asError(String message) {
    state = ParseState.Error;
    error = message;
    return this;
  }

  bool findBindings(AppBinding b) {
    return b.label.toLowerCase() == incomplete.toLowerCase();
  }

  Future<ParsedCommand> matchBinding(List<AppBinding> commandBindings, {bool autocompleteMode = false}) async {
    if (commandBindings.isEmpty) {
      return asError(intl.appsErrorParserNoBindings);
    }
    List<AppBinding> bindings = commandBindings;

    bool done = false;
    while (!done) {
      String c = '';
      if (i < command.length) {
        c = command[i];
      }

      switch (state) {
        case ParseState.Start:
          if (c != '/') {
            return asError(intl.appsErrorParserNoSlashStart);
          }
          i++;
          incomplete = '';
          incompleteStart = i;
          state = ParseState.Command;
          break;

        case ParseState.Command:
          if (c.isEmpty) {
            if (autocompleteMode) {
              done = true;
            } else {
              state = ParseState.EndCommand;
            }
          } else if (c == ' ' || c == '	') {
            state = ParseState.EndCommand;
          } else {
            incomplete += c;
            i++;
          }
          break;

        case ParseState.EndCommand:
          var binding = bindings.firstWhere(findBindings, orElse: () => null);
          if (binding == null) {
            done = true;
            break;
          }
          this.binding = binding;
          location += '/' + binding.label;
          bindings = binding.bindings ?? [];
          state = ParseState.CommandSeparator;
          break;

        case ParseState.CommandSeparator:
          if (c.isEmpty) {
            done = true;
          } else if (c == ' ' || c == '	') {
            i++;
          } else {
            incomplete = '';
            incompleteStart = i;
            state = ParseState.Command;
          }
          break;

        default:
          return asError(intl.appsErrorParserUnexpectedState(state.toString()));
      }
    }

    if (binding == null) {
      if (autocompleteMode) {
        return this;
      }
      return asError(intl.appsErrorParserNoMatch(command));
    }

    if (!autocompleteMode && binding!.bindings?.isNotEmpty == true) {
      return asError(intl.appsErrorParserExecuteNonLeaf);
    }

    if (binding!.bindings?.isEmpty == true) {
      if (binding!.submit != null && binding!.form == null) {
        resolvedForm = AppForm(submit: binding!.submit);
      } else if (binding!.form != null && binding!.submit == null) {
        var form = binding!.form;
        if (form!.submit == null) {
          var fetched = await formsCache.getSubmittableForm(location, binding!);
          if (fetched?.containsKey('error') == true) {
            return asError(fetched!['error']);
          }
          resolvedForm = fetched!['form'];
        }
        resolvedForm = binding!.form;
      } else {
        return asError(intl.appsErrorParserUnreachableInvalidBinding);
      }
    }
    return this;
  }

  ParsedCommand parseForm({bool autocompleteMode = false}) {
    if (state == ParseState.Error || resolvedForm == null) {
      return this;
    }

    List<AppField> fields = resolvedForm!.fields ?? [];
    fields = fields.where((f) => f.type != AppFieldTypes.MARKDOWN && !f.readonly).toList();
    state = ParseState.StartParameter;
    i = incompleteStart;

    bool flagEqualsUsed = false;
    bool escaped = false;

    while (true) {
      String c = '';
      if (i < command.length) {
        c = command[i];
      }

      switch (state) {
        case ParseState.StartParameter:
          if (c.isEmpty) {
            return this;
          } else if (c == '-') {
            state = ParseState.Flag1;
            i++;
          } else if (c == '—') {
            state = ParseState.Flag;
            i++;
            incomplete = '';
            incompleteStart = i;
            flagEqualsUsed = false;
          } else {
            position++;
            var field = fields.firstWhere((f) => f.position == position, orElse: () => fields.firstWhere((f) => f.position == -1 && f.type == AppFieldTypes.TEXT && !values.containsKey(f.name)));
            if (field == null) {
              return asError(intl.appsErrorParserNoArgumentPosX);
            }
            incompleteStart = i;
            incomplete = '';
            this.field = field;
            state = ParseState.Rest;
          }
          break;

        case ParseState.Rest:
          if (field == null) {
            return asError(intl.appsErrorParserMissingFieldValue);
          }
          if (autocompleteMode && c.isEmpty) {
            return this;
          }
          if (c.isEmpty) {
            values[field!.name] = incomplete;
            return this;
          }
          i++;
          incomplete += c;
          break;

        case ParseState.ParameterSeparator:
          incompleteStart = i;
          if (c.isEmpty) {
            state = ParseState.StartParameter;
            return this;
          } else if (c == ' ' || c == '	') {
            i++;
          } else {
            state = ParseState.StartParameter;
          }
          break;

        case ParseState.Flag1:
          if (c == '-') {
            i++;
          }
          state = ParseState.Flag;
          incomplete = '';
          incompleteStart = i;
          flagEqualsUsed = false;
          break;

        case ParseState.Flag:
          if (c.isEmpty && autocompleteMode) {
            return this;
          }
          if (c.isEmpty || c == ' ' || c == '	' || c == '=') {
            var field = fields.firstWhere((f) => f.label?.toLowerCase() == incomplete.toLowerCase(), orElse: () => null);
            if (field == null) {
              return asError(intl.appsErrorParserUnexpectedFlag(incomplete));
            }
            state = ParseState.FlagValueSeparator;
            this.field = field;
            incomplete = '';
          } else {
            incomplete += c;
            i++;
          }
          break;

        case ParseState.FlagValueSeparator:
          incompleteStart = i;
          if (c.isEmpty) {
            if (autocompleteMode) {
              return this;
            }
            state = ParseState.StartValue;
          } else if (c == ' ' || c == '	') {
            i++;
          } else if (c == '=') {
            if (flagEqualsUsed) {
              return asError(intl.appsErrorParserMultipleEqual);
            }
            flagEqualsUsed = true;
            i++;
          } else {
            state = ParseState.StartValue;
          }
          break;

        case ParseState.StartValue:
          incomplete = '';
          incompleteStart = i;
          if (c == '"') {
            state = ParseState.QuotedValue;
            i++;
          } else if (c == '`') {
            state = ParseState.TickValue;
            i++;
          } else if (c == ' ' || c == '	') {
            return asError(intl.appsErrorParserUnexpectedWhitespace);
          } else if (c == '[' && field?.multiselect == true) {
            state = ParseState.MultiselectStart;
            i++;
          } else {
            state = ParseState.NonspaceValue;
          }
          break;

        case ParseState.NonspaceValue:
          if (c.isEmpty || c == ' ' || c == '	') {
            state = ParseState.EndValue;
          } else {
            incomplete += c;
            i++;
          }
          break;

        case ParseState.QuotedValue:
          if (c.isEmpty) {
            if (!autocompleteMode) {
              return asError(intl.appsErrorParserMissingQuote);
            }
            return this;
          } else if (c == '"') {
            if (incompleteStart == i - 1) {
              return asError(intl.appsErrorParserEmptyValue);
            }
            i++;
            state = ParseState.EndQuotedValue;
          } else if (c == '\') {
            escaped = true;
            i++;
          } else {
            incomplete += c;
            i++;
            if (escaped) {
              escaped = false;
            }
          }
          break;

        case ParseState.TickValue:
          if (c.isEmpty) {
            if (!autocompleteMode) {
              return asError(intl.appsErrorParserMissingTick);
            }
            return this;
          } else if (c == '`') {
            if (incompleteStart == i - 1) {
              return asError(intl.appsErrorParserEmptyValue);
            }
            i++;
            state = ParseState.EndTickedValue;
          } else {
            incomplete += c;
            i++;
          }
          break;

        case ParseState.EndTickedValue:
        case ParseState.EndQuotedValue:
        case ParseState.EndValue:
          if (field == null) {
            return asError(intl.appsErrorParserMissingFieldValue);
          }
          if (field!.type == AppFieldTypes.BOOL && (!autocompleteMode && incomplete != 'true' && incomplete != 'false')) {
            i = incompleteStart;
            values[field!.name] = 'true';
            state = ParseState.StartParameter;
          } else {
            if (autocompleteMode && c.isEmpty) {
              return this;
            }
            values[field!.name] = incomplete;
            incomplete = '';
            incompleteStart = i;
            if (c.isEmpty) {
              return this;
            }
            state = ParseState.ParameterSeparator;
          }
          break;

        case ParseState.MultiselectStart:
          if (field == null) {
            return asError(intl.appsErrorParserMissingFieldValue);
          }
          values[field!.name] = [];
          if (c == ' ' || c == '	') {
            i++;
          } else if (c == ']') {
            i++;
            state = ParseState.ParameterSeparator;
          } else {
            state = ParseState.MultiselectStartValue;
          }
          break;

        case ParseState.MultiselectStartValue:
          incomplete = '';
          incompleteStart = i;
          if (c.isEmpty) {
            if (!autocompleteMode) {
              return asError(intl.appsErrorParserMissingListEnd);
            }
            return this;
          } else if (c == '"') {
            state = ParseState.MultiselectQuotedValue;
            i++;
          } else if (c == '`') {
            state = ParseState.MultiselectTickValue;
            i++;
          } else if (c == ' ' || c == '	') {
            return asError(intl.appsErrorParserUnexpectedWhitespace);
          } else if (c == ',') {
            return asError(intl.appsErrorParserUnexpectedComma);
          } else {
            state = ParseState.MultiselectNonspaceValue;
          }
          break;

        case ParseState.MultiselectNonspaceValue:
          if (c.isEmpty || c == ' ' || c == '	' || c == ',' || c == ']') {
            state = ParseState.MultiselectEndValue;
          } else {
            incomplete += c;
            i++;
          }
          break;

        case ParseState.MultiselectQuotedValue:
          if (c.isEmpty) {
            if (!autocompleteMode) {
              return asError(intl.appsErrorParserMissingQuote);
            }
            return this;
          } else if (c == '"') {
            if (incompleteStart == i - 1) {
              return asError(intl.appsErrorParserEmptyValue);
            }
            i++;
            state = ParseState.MultiselectEndQuotedValue;
          } else if (c == '\') {
            escaped = true;
            i++;
          } else {
            incomplete += c;
            i++;
            if (escaped) {
              escaped = false;
            }
          }
          break;

        case ParseState.MultiselectTickValue:
          if (c.isEmpty) {
            if (!autocompleteMode) {
              return asError(intl.appsErrorParserMissingTick);
            }
            return this;
          } else if (c == '`') {
            if (incompleteStart == i - 1) {
              return asError(intl.appsErrorParserEmptyValue);
            }
            i++;
            state = ParseState.MultiselectEndTickedValue;
          } else {
            incomplete += c;
            i++;
          }
          break;

        case ParseState.MultiselectEndTickedValue:
        case ParseState.MultiselectEndQuotedValue:
        case ParseState.MultiselectEndValue:
          if (field == null) {
            return asError(intl.appsErrorParserMissingFieldValue);
          }
          if (autocompleteMode && c.isEmpty) {
            return this;
          }
          (values[field!.name] as List<String>).add(incomplete);
          incomplete = '';
          incompleteStart = i;
          if (c.isEmpty) {
            return this;
          }
          state = ParseState.MultiselectValueSeparator;
          break;

        case ParseState.MultiselectValueSeparator:
          if (c.isEmpty) {
            if (!autocompleteMode) {
              return asError(intl.appsErrorParserMissingListEnd);
            }
            return this;
          } else if (c == ']') {
            i++;
            state = ParseState.ParameterSeparator;
          } else if (c == ' ' || c == '	') {
            i++;
          } else if (c == ',') {
            i++;
            state = ParseState.MultiselectNextValue;
          } else {
            return asError(intl.appsErrorParserUnexpectedCharacter);
          }
          break;

        case ParseState.MultiselectNextValue:
          if (c == ' ' || c == '	') {
            i++;
          } else {
            state = ParseState.MultiselectStartValue;
          }
          break;

        default:
          return asError(intl.appsErrorParserUnexpectedState(state.toString()));
      }
    }
  }
}
