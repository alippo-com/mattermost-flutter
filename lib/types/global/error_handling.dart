// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

abstract class JsAndNativeErrorHandler {
  void initializeErrorHandling();
  void nativeErrorHandler(String e);
  void errorHandler(dynamic e, bool isFatal);
}