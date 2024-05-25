// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

String generateGroupAssociationId(String groupId, String otherId) {
  return '${groupId}-${otherId}';
}