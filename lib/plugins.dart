// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

abstract class ClientPluginsMix {
  Future<List<ClientPluginManifest>> getPluginsManifests();
}

class ClientPlugins<TBase extends ClientBase> extends TBase {
  Future<List<ClientPluginManifest>> getPluginsManifests() async {
    return this.doFetch(
      '${this.getPluginsRoute()}/webapp',
      'GET',
    );
  }
}