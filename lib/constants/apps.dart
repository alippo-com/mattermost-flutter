// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

const Map<String, String> AppBindingLocations = {
    'POST_MENU_ITEM': '/post_menu',
    'CHANNEL_HEADER_ICON': '/channel_header',
    'COMMAND': '/command',
    'IN_POST': '/in_post',
};

const Map<String, String> AppBindingPresentations = {
    'MODAL': 'modal',
};

const Map<String, String> AppCallResponseTypes = {
    'OK': 'ok',
    'ERROR': 'error',
    'FORM': 'form',
    'CALL': 'call',
    'NAVIGATE': 'navigate',
};

const Map<String, String> AppExpandLevels = {
    'EXPAND_DEFAULT': '',
    'EXPAND_NONE': 'none',
    'EXPAND_ALL': 'all',
    'EXPAND_SUMMARY': 'summary',
};

const Map<String, String> AppFieldTypes = {
    'TEXT': 'text',
    'STATIC_SELECT': 'static_select',
    'DYNAMIC_SELECT': 'dynamic_select',
    'BOOL': 'bool',
    'USER': 'user',
    'CHANNEL': 'channel',
    'MARKDOWN': 'markdown',
};

const List<String> SelectableAppFieldTypes = [
    AppFieldTypes['CHANNEL'],
    AppFieldTypes['USER'],
    AppFieldTypes['STATIC_SELECT'],
    AppFieldTypes['DYNAMIC_SELECT'],
];

const String COMMAND_SUGGESTION_ERROR = 'error';
const String COMMAND_SUGGESTION_CHANNEL = 'channel';
const String COMMAND_SUGGESTION_USER = 'user';

final Map<String, dynamic> constants = {
    'AppBindingLocations': AppBindingLocations,
    'AppBindingPresentations': AppBindingPresentations,
    'AppCallResponseTypes': AppCallResponseTypes,
    'AppExpandLevels': AppExpandLevels,
    'AppFieldTypes': AppFieldTypes,
    'COMMAND_SUGGESTION_ERROR': COMMAND_SUGGESTION_ERROR,
    'COMMAND_SUGGESTION_CHANNEL': COMMAND_SUGGESTION_CHANNEL,
    'COMMAND_SUGGESTION_USER': COMMAND_SUGGESTION_USER,
};