// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

const int MAX_MESSAGE_LENGTH_FALLBACK = 4000;
const int DEFAULT_SERVER_MAX_FILE_SIZE = 50 * 1024 * 1024;// 50 Mb
const int ICON_SIZE = 24;
const int TYPING_HEIGHT = 16;
const String ACCESSORIES_CONTAINER_NATIVE_ID = 'channelAccessoriesContainer';
const String THREAD_ACCESSORIES_CONTAINER_NATIVE_ID = 'threadAccessoriesContainer';

const int NOTIFY_ALL_MEMBERS = 5;

final Map<String, dynamic> postDraftConstants = {
    'ACCESSORIES_CONTAINER_NATIVE_ID': ACCESSORIES_CONTAINER_NATIVE_ID,
    'DEFAULT_SERVER_MAX_FILE_SIZE': DEFAULT_SERVER_MAX_FILE_SIZE,
    'ICON_SIZE': ICON_SIZE,
    'MAX_MESSAGE_LENGTH_FALLBACK': MAX_MESSAGE_LENGTH_FALLBACK,
    'NOTIFY_ALL_MEMBERS': NOTIFY_ALL_MEMBERS,
    'TYPING_HEIGHT': TYPING_HEIGHT,
};