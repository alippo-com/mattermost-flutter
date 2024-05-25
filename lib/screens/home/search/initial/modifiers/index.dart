import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/home/search/team_picker_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'modifier.dart';
import 'show_more.dart';

import 'package:mattermost_flutter/types/database/models/servers/team.dart';
import 'package:mattermost_flutter/types/search.dart';

const MODIFIER_LABEL_HEIGHT = 48.0;
const TEAM_PICKER_ICON_SIZE = 32.0;
const NUM_ITEMS_BEFORE_EXPAND = 4;

class Modifiers extends HookWidget {
  final ValueNotifier<bool> scrollEnabled;
  final TextEditingController searchController;
  final ValueNotifier<String> searchValue;
  final Function(String) setTeamId;
  final String teamId;
  final List<TeamModel> teams;

  Modifiers({
    required this.scrollEnabled,
    required this.searchController,
    required this.searchValue,
    required this.setTeamId,
    required this.teamId,
    required this.teams,
  });

  List<ModifierItem> getModifiersSectionsData(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    return [
      ModifierItem(term: 'From:', testID: 'search.modifier.from', description: intl.translate('mobile.search.modifier.from')),
      ModifierItem(term: 'In:', testID: 'search.modifier.in', description: intl.translate('mobile.search.modifier.in')),
      ModifierItem(term: '-', testID: 'search.modifier.exclude', description: intl.translate('mobile.search.modifier.exclude')),
      ModifierItem(term: '""', testID: 'search.modifier.phrases', description: intl.translate('mobile.search.modifier.phrases'), cursorPosition: -1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = AppLocalizations.of(context)!;
    final showMore = useState(false);
    final height = useState(NUM_ITEMS_BEFORE_EXPAND * MODIFIER_LABEL_HEIGHT);
    final data = useMemo(() => getModifiersSectionsData(context), [intl]);
    final timeoutRef = useRef<Timer?>(null);

    final styles = getStyleFromTheme(theme);

    void handleShowMore() {
      final nextShowMore = !showMore.value;
      showMore.value = nextShowMore;
      scrollEnabled.value = false;
      height.value = (nextShowMore ? data.length : NUM_ITEMS_BEFORE_EXPAND) * MODIFIER_LABEL_HEIGHT;

      if (timeoutRef.current != null) {
        timeoutRef.current!.cancel();
      }
      timeoutRef.current = Timer(Duration(milliseconds: 350), () {
        scrollEnabled.value = true;
      });
    }

    useEffect(() {
      return () {
        if (timeoutRef.current != null) {
          timeoutRef.current!.cancel();
        }
      };
    }, []);

    Widget renderModifier(ModifierItem item) {
      return Modifier(
        key: Key(item.term),
        item: item,
        searchController: searchController,
        searchValue: searchValue,
      );
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 20.0, right: 18.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: FormattedText(
                    style: TextStyle(
                      color: theme.centerChannelColor,
                      fontSize: typography('Heading', 300, 'SemiBold'),
                    ),
                    id: 'screen.search.modifier.header',
                    defaultMessage: 'Search options',
                    testID: 'search.modifier.header',
                  ),
                ),
              ),
              if (teams.length > 1)
                TeamPickerIcon(
                  size: TEAM_PICKER_ICON_SIZE,
                  setTeamId: setTeamId,
                  teamId: teamId,
                  teams: teams,
                ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: height.value,
          width: double.infinity,
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => renderModifier(data[index]),
          ),
        ),
        if (data.length > NUM_ITEMS_BEFORE_EXPAND)
          ShowMoreButton(
            onPress: handleShowMore,
            showMore: showMore.value,
          ),
      ],
    );
  }
}

class Timeout {
  final Timer _timer;

  Timeout(void Function() callback, Duration duration)
      : _timer = Timer(duration, callback);

  void cancel() {
    _timer.cancel();
  }
}
