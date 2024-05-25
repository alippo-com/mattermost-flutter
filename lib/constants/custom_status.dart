// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/i18n.dart';

enum CustomStatusDurationEnum {
    dontClear,
    thirtyMinutes,
    oneHour,
    fourHours,
    today,
    thisWeek,
    dateAndTime,
}

const Map<CustomStatusDurationEnum, CustomStatus> customStatusDurations = {
    CustomStatusDurationEnum.dontClear: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.dont_clear'), defaultMessage: "Don't clear"),
    CustomStatusDurationEnum.thirtyMinutes: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.thirty_minutes'), defaultMessage: '30 minutes'),
    CustomStatusDurationEnum.oneHour: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.one_hour'), defaultMessage: '1 hour'),
    CustomStatusDurationEnum.fourHours: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.four_hours'), defaultMessage: '4 hours'),
    CustomStatusDurationEnum.today: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.today'), defaultMessage: 'Today'),
    CustomStatusDurationEnum.thisWeek: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.this_week'), defaultMessage: 'This week'),
    CustomStatusDurationEnum.dateAndTime: CustomStatus(id: I18n.t('custom_status.expiry_dropdown.date_and_time'), defaultMessage: 'Date and Time'),
};

const int customStatusTextCharacterLimit = 100;

const String setCustomStatusFailure = 'set_custom_status_failure';

const int customStatusTimePickerIntervalsInMinutes = 30;
