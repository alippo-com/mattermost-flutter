// Converted from TypeScript (React Native) to Dart (Flutter)

import '../../mattermost_flutter/base.dart'; // Assuming base.dart is the Dart equivalent of base.ts

abstract class ClientPluginsMix {
  Future<List<ClientPluginManifest>> getPluginsManifests();
}

class ClientPlugins<TBase extends ClientBase> extends TBase {
  ClientPlugins(superclass) : super(superclass);

  @override
  Future<List<ClientPluginManifest>> getPluginsManifests() async {
    return doFetch(
      "${getPluginsRoute()}/webapp",
      method: 'GET',
    );
  }
}
