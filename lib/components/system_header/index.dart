
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/user.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/formatted_time.dart';
import 'package:rxdart/rxdart.dart';

class SystemHeader extends StatelessWidget {
  final bool isMilitaryTime;
  final dynamic createAt;
  final Theme theme;
  final UserModel? user;

  SystemHeader({
    required this.isMilitaryTime,
    required this.createAt,
    required this.theme,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(theme);
    final userTimezone = getUserTimezone(user);

    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: 5),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: FormattedText(
            id: 'post_info.system',
            defaultMessage: 'System',
            style: styles['displayName'],
            testID: 'post_header.display_name',
          ),
        ),
        FormattedTime(
          timezone: userTimezone ?? '',
          isMilitaryTime: isMilitaryTime,
          value: createAt,
          style: styles['time'],
          testID: 'post_header.date_time',
        ),
      ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'displayName': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ).merge(typography('Body', 200, 'SemiBold')),
      'time': TextStyle(
        color: theme.centerChannelColor,
        opacity: 0.5,
        fontSize: 12.0,
      ).merge(typography('Body', 75, 'Regular')),
    };
  }
}

class EnhancedSystemHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final preferences = queryDisplayNamePreferences(database, 'use_military_time').observeWithColumns(['value']);
    final isMilitaryTime = preferences.map((prefs) => getDisplayNamePreferenceAsBool(prefs, 'use_military_time'));
    final user = observeCurrentUser(database);

    return StreamBuilder(
      stream: CombineLatestStream.combine2(isMilitaryTime, user, (bool isMilitaryTime, UserModel user) {
        return {
          'isMilitaryTime': isMilitaryTime,
          'user': user,
        };
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;

        return SystemHeader(
          isMilitaryTime: data['isMilitaryTime'],
          createAt: DateTime.now(), // Replace with actual date
          theme: Provider.of<Theme>(context),
          user: data['user'],
        );
      },
    );
  }
}
