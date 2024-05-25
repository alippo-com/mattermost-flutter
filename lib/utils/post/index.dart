
Future<void> persistentNotificationsConfirmation(
  String serverUrl,
  String value,
  List<String> mentionsList,
  Intl intl,
  Function sendMessage,
  int persistentNotificationMaxRecipients,
  int persistentNotificationInterval,
  String currentUserId,
  {String channelName, String channelType}
) async {
  String title = '';
  String description = '';
  List<AlertDialogButton> buttons = [
    AlertDialogButton(
      text: intl.formatMessage({
        'id': 'persistent_notifications.error.okay',
        'defaultMessage': 'Okay',
      }),
      style: AlertDialogButtonStyle.cancel,
    ),
  ];

  if (channelType == General.DM_CHANNEL) {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final teammateId = getUserIdFromChannelName(currentUserId, channelName);
    final user = await getUserById(database, teammateId);

    title = intl.formatMessage({
      'id': 'persistent_notifications.confirm.title',
      'defaultMessage': 'Send persistent notifications',
    });
    description = intl.formatMessage({
      'id': 'persistent_notifications.dm_channel.description',
      'defaultMessage': '@{username} will be notified every {interval, plural, one {minute} other {{interval} minutes}} until they’ve acknowledged or replied to the message.',
    }, {
      'interval': persistentNotificationInterval,
      'username': user?.username,
    });
    buttons = [
      AlertDialogButton(
        text: intl.formatMessage({
          'id': 'persistent_notifications.confirm.cancel',
          'defaultMessage': 'Cancel',
        }),
        style: AlertDialogButtonStyle.cancel,
      ),
      AlertDialogButton(
        text: intl.formatMessage({
          'id': 'persistent_notifications.confirm.send',
          'defaultMessage': 'Send',
        }),
        onPressed: sendMessage,
      ),
    ];
  } else if (hasSpecialMentions(value)) {
    description = intl.formatMessage({
      'id': 'persistent_notifications.error.special_mentions',
      'defaultMessage': 'Cannot use @channel, @all or @here to mention recipients of persistent notifications.',
    });
  } else {
    final formattedMentionsList = mentionsList.map((mention) => mention.substring(1)).toList();
    final usersCount = await getUsersCountFromMentions(serverUrl, formattedMentionsList);
    if (usersCount == 0) {
      title = intl.formatMessage({
        'id': 'persistent_notifications.error.no_mentions.title',
        'defaultMessage': 'Recipients must be @mentioned',
      });
      description = intl.formatMessage({
        'id': 'persistent_notifications.error.no_mentions.description',
        'defaultMessage': 'There are no recipients mentioned in your message. You’ll need add mentions to be able to send persistent notifications.',
      });
    } else if (usersCount > persistentNotificationMaxRecipients) {
      title = intl.formatMessage({
        'id': 'persistent_notifications.error.max_recipients.title',
        'defaultMessage': 'Too many recipients',
      });
      description = intl.formatMessage({
        'id': 'persistent_notifications.error.max_recipients.description',
        'defaultMessage': 'You can send persistent notifications to a maximum of {max} recipients. There are {count} recipients mentioned in your message. You’ll need to change who you’ve mentioned before you can send.',
      }, {
        'max': persistentNotificationMaxRecipients,
        'count': mentionsList.length,
      });
    } else {
      title = intl.formatMessage({
        'id': 'persistent_notifications.confirm.title',
        'defaultMessage': 'Send persistent notifications',
      });
      description = intl.formatMessage({
        'id': 'persistent_notifications.confirm.description',
        'defaultMessage': 'Mentioned recipients will be notified every {interval, plural, one {minute} other {{interval} minutes}} until they’ve acknowledged or replied to the message.',
      }, {
        'interval': persistentNotificationInterval,
      });

      buttons = [
        AlertDialogButton(
          text: intl.formatMessage({
            'id': 'persistent_notifications.confirm.cancel',
            'defaultMessage': 'Cancel',
          }),
          style: AlertDialogButtonStyle.cancel,
        ),
        AlertDialogButton(
          text: intl.formatMessage({
            'id': 'persistent_notifications.confirm.send',
            'defaultMessage': 'Send',
          }),
          onPressed: sendMessage,
        ),
      ];
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: buttons.map((button) {
          return TextButton(
            onPressed: button.onPressed,
            child: Text(button.text),
          );
        }).toList(),
      );
    },
  );
}
