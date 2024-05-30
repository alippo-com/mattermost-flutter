
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_flutter_project/utils/apps.dart';
import 'package:your_flutter_project/utils/theme.dart';
import 'package:your_flutter_project/utils/tap.dart';
import 'package:your_flutter_project/screens/navigation.dart';
import 'package:your_flutter_project/actions/remote/apps.dart';
import 'package:your_flutter_project/actions/remote/command.dart';
import 'package:your_flutter_project/constants/apps.dart';
import 'package:your_flutter_project/context/server.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ButtonBinding extends HookWidget {
  final String currentTeamId;
  final AppBinding binding;
  final PostModel post;
  final String? teamID;
  final ThemeData theme;

  const ButtonBinding({
    Key? key,
    required this.currentTeamId,
    required this.binding,
    required this.post,
    this.teamID,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);
    final intl = AppLocalizations.of(context)!;
    final serverUrl = Provider.of<ServerNotifier>(context).serverUrl;
    final style = _getStyleSheet(theme);

    Future<void> onPress() async {
      if (pressed.value) {
        return;
      }

      pressed.value = true;

      final context = createCallContext(
        binding.appId,
        AppBindingLocations.inPost + binding.location,
        post.channelId,
        teamID ?? currentTeamId,
        post.id,
      );

      final res = await handleBindingClick(serverUrl, binding, context, intl);
      pressed.value = false;

      if (res.error != null) {
        final errorResponse = res.error!;
        final errorMessage = errorResponse.text ?? intl.translate('apps.error.unknown', 'Unknown error occurred.');
        postEphemeralCallResponseForPost(serverUrl, errorResponse, errorMessage, post);
        return;
      }

      final callResp = res.data!;

      switch (callResp.type) {
        case AppCallResponseTypes.ok:
          if (callResp.text != null) {
            postEphemeralCallResponseForPost(serverUrl, callResp, callResp.text!, post);
          }
          return;
        case AppCallResponseTypes.navigate:
          if (callResp.navigateToUrl != null) {
            handleGotoLocation(serverUrl, intl, callResp.navigateToUrl!);
          }
          return;
        case AppCallResponseTypes.form:
          if (callResp.form != null) {
            showAppForm(callResp.form!, context);
          }
          return;
        default:
          final errorMessage = intl.translate(
            'apps.error.responses.unknown_type',
            'App response type not supported. Response type: {type}.',
            {'type': callResp.type},
          );
          postEphemeralCallResponseForPost(serverUrl, callResp, errorMessage, post);
      }
    }

    return GestureDetector(
      onTap: preventDoubleTap(onPress),
      child: Container(
        decoration: style.button,
        child: Center(
          child: Text(
            binding.label,
            style: style.text,
          ),
        ),
      ),
    );
  }

  _Styles _getStyleSheet(ThemeData theme) {
    final statusColors = getStatusColors(theme);

    return _Styles(
      button: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColors.default.withOpacity(0.25), width: 2),
      ),
      buttonDisabled: BoxDecoration(
        color: theme.buttonColor.withOpacity(0.3),
      ),
      text: TextStyle(
        color: statusColors.default,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.1,
        fontFamily: 'OpenSans-SemiBold',
      ),
    );
  }
}

class _Styles {
  final BoxDecoration button;
  final BoxDecoration buttonDisabled;
  final TextStyle text;

  _Styles({required this.button, required this.buttonDisabled, required this.text});
}
