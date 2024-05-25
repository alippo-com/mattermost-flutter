import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostPriorityLabels {
  static final labels = {
    'standard': {
      'label': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelStandard,
        'defaultMessage': 'Standard',
      },
    },
    'urgent': {
      'label': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelUrgent,
        'defaultMessage': 'Urgent',
      },
    },
    'important': {
      'label': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelImportant,
        'defaultMessage': 'Important',
      },
    },
    'requestAck': {
      'label': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelRequestAck,
        'defaultMessage': 'Request acknowledgement',
      },
      'description': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelRequestAckDescription,
        'defaultMessage': 'An acknowledgement button will appear with your message',
      },
    },
    'persistentNotifications': {
      'label': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelPersistentNotifications,
        'defaultMessage': 'Send persistent notifications',
      },
      'description': {
        'id': AppLocalizations.of(context)!.postPriorityPickerLabelPersistentNotificationsDescription,
        'defaultMessage': 'Recipients are notified every {interval, plural, one {minute} other {{interval} minutes}} until they acknowledge or reply.',
      },
    },
  };
}