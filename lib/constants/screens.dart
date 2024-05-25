
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

final ABOUT = 'About';
final ACCOUNT = 'Account';
final APPS_FORM = 'AppForm';
final BOTTOM_SHEET = 'BottomSheet';
final BROWSE_CHANNELS = 'BrowseChannels';
final CALL = 'Call';
final CALL_PARTICIPANTS = 'CallParticipants';
final CALL_HOST_CONTROLS = 'CallHostControls';
final CHANNEL = 'Channel';
final CHANNEL_ADD_MEMBERS = 'ChannelAddMembers';
final CHANNEL_FILES = 'ChannelFiles';
final CHANNEL_INFO = 'ChannelInfo';
final CHANNEL_NOTIFICATION_PREFERENCES = 'ChannelNotificationPreferences';
final CODE = 'Code';
final CONVERT_GM_TO_CHANNEL = 'ConvertGMToChannel';
final CREATE_DIRECT_MESSAGE = 'CreateDirectMessage';
final CREATE_OR_EDIT_CHANNEL = 'CreateOrEditChannel';
final CREATE_TEAM = 'CreateTeam';
final CUSTOM_STATUS = 'CustomStatus';
final CUSTOM_STATUS_CLEAR_AFTER = 'CustomStatusClearAfter';
final EDIT_POST = 'EditPost';
final EDIT_PROFILE = 'EditProfile';
final EDIT_SERVER = 'EditServer';
final EMOJI_PICKER = 'EmojiPicker';
final FIND_CHANNELS = 'FindChannels';
final FORGOT_PASSWORD = 'ForgotPassword';
final GALLERY = 'Gallery';
final GLOBAL_THREADS = 'GlobalThreads';
final HOME = 'Home';
final INTEGRATION_SELECTOR = 'IntegrationSelector';
final INTERACTIVE_DIALOG = 'InteractiveDialog';
final INVITE = 'Invite';
final IN_APP_NOTIFICATION = 'InAppNotification';
final JOIN_TEAM = 'JoinTeam';
final LATEX = 'Latex';
final LOGIN = 'Login';
final MANAGE_CHANNEL_MEMBERS = 'ManageChannelMembers';
final MENTIONS = 'Mentions';
final MFA = 'MFA';
final ONBOARDING = 'Onboarding';
final PERMALINK = 'Permalink';
final PINNED_MESSAGES = 'PinnedMessages';
final POST_OPTIONS = 'PostOptions';
final POST_PRIORITY_PICKER = 'PostPriorityPicker';
final REACTIONS = 'Reactions';
final REVIEW_APP = 'ReviewApp';
final SAVED_MESSAGES = 'SavedMessages';
final SEARCH = 'Search';
final SELECT_TEAM = 'SelectTeam';
final SERVER = 'Server';
final SETTINGS = 'Settings';
final SETTINGS_ADVANCED = 'SettingsAdvanced';
final SETTINGS_DISPLAY = 'SettingsDisplay';
final SETTINGS_DISPLAY_CLOCK = 'SettingsDisplayClock';
final SETTINGS_DISPLAY_CRT = 'SettingsDisplayCRT';
final SETTINGS_DISPLAY_THEME = 'SettingsDisplayTheme';
final SETTINGS_DISPLAY_TIMEZONE = 'SettingsDisplayTimezone';
final SETTINGS_DISPLAY_TIMEZONE_SELECT = 'SettingsDisplayTimezoneSelect';
final SETTINGS_NOTIFICATION = 'SettingsNotification';
final SETTINGS_NOTIFICATION_AUTO_RESPONDER = 'SettingsNotificationAutoResponder';
final SETTINGS_NOTIFICATION_EMAIL = 'SettingsNotificationEmail';
final SETTINGS_NOTIFICATION_MENTION = 'SettingsNotificationMention';
final SETTINGS_NOTIFICATION_PUSH = 'SettingsNotificationPush';
final SHARE_FEEDBACK = 'ShareFeedback';
final SNACK_BAR = 'SnackBar';
final SSO = 'SSO';
final TABLE = 'Table';
final TEAM_SELECTOR_LIST = 'TeamSelectorList';
final TERMS_OF_SERVICE = 'TermsOfService';
final THREAD = 'Thread';
final THREAD_FOLLOW_BUTTON = 'ThreadFollowButton';
final THREAD_OPTIONS = 'ThreadOptions';
final USER_PROFILE = 'UserProfile';

final screens = {
    ABOUT,
    ACCOUNT,
    APPS_FORM,
    BOTTOM_SHEET,
    BROWSE_CHANNELS,
    CALL,
    CALL_PARTICIPANTS,
    CALL_HOST_CONTROLS,
    CHANNEL,
    CHANNEL_ADD_MEMBERS,
    CHANNEL_FILES,
    CHANNEL_INFO,
    CHANNEL_NOTIFICATION_PREFERENCES,
    CODE,
    CONVERT_GM_TO_CHANNEL,
    CREATE_DIRECT_MESSAGE,
    CREATE_OR_EDIT_CHANNEL,
    CREATE_TEAM,
    CUSTOM_STATUS,
    CUSTOM_STATUS_CLEAR_AFTER,
    EDIT_POST,
    EDIT_PROFILE,
    EDIT_SERVER,
    EMOJI_PICKER,
    FIND_CHANNELS,
    FORGOT_PASSWORD,
    GALLERY,
    GLOBAL_THREADS,
    HOME,
    INTEGRATION_SELECTOR,
    INTERACTIVE_DIALOG,
    INVITE,
    IN_APP_NOTIFICATION,
    JOIN_TEAM,
    LATEX,
    LOGIN,
    MANAGE_CHANNEL_MEMBERS,
    MENTIONS,
    MFA,
    ONBOARDING,
    PERMALINK,
    PINNED_MESSAGES,
    POST_OPTIONS,
    POST_PRIORITY_PICKER,
    REACTIONS,
    REVIEW_APP,
    SAVED_MESSAGES,
    SEARCH,
    SELECT_TEAM,
    SERVER,
    SETTINGS,
    SETTINGS_ADVANCED,
    SETTINGS_DISPLAY,
    SETTINGS_DISPLAY_CLOCK,
    SETTINGS_DISPLAY_CRT,
    SETTINGS_DISPLAY_THEME,
    SETTINGS_DISPLAY_TIMEZONE,
    SETTINGS_DISPLAY_TIMEZONE_SELECT,
    SETTINGS_NOTIFICATION,
    SETTINGS_NOTIFICATION_AUTO_RESPONDER,
    SETTINGS_NOTIFICATION_EMAIL,
    SETTINGS_NOTIFICATION_MENTION,
    SETTINGS_NOTIFICATION_PUSH,
    SHARE_FEEDBACK,
    SNACK_BAR,
    SSO,
    TABLE,
    TEAM_SELECTOR_LIST,
    TERMS_OF_SERVICE,
    THREAD,
    THREAD_FOLLOW_BUTTON,
    THREAD_OPTIONS,
    USER_PROFILE,
} as final;

final MODAL_SCREENS_WITHOUT_BACK = Set<String>.from([
    BROWSE_CHANNELS,
    CHANNEL_INFO,
    CHANNEL_ADD_MEMBERS,
    CREATE_DIRECT_MESSAGE,
    CREATE_TEAM,
    CUSTOM_STATUS,
    EDIT_POST,
    EDIT_PROFILE,
    EDIT_SERVER,
    FIND_CHANNELS,
    GALLERY,
    MANAGE_CHANNEL_MEMBERS,
    INVITE,
    PERMALINK,
]);

final SCREENS_WITH_TRANSPARENT_BACKGROUND = Set<String>.from([
    PERMALINK,
    REVIEW_APP,
    SNACK_BAR,
]);

final SCREENS_AS_BOTTOM_SHEET = Set<String>.from([
    BOTTOM_SHEET,
    EMOJI_PICKER,
    POST_OPTIONS,
    POST_PRIORITY_PICKER,
    THREAD_OPTIONS,
    REACTIONS,
    USER_PROFILE,
    CALL_PARTICIPANTS,
    CALL_HOST_CONTROLS,
]);

final NOT_READY = List<String>.from([
    CREATE_TEAM,
]);
