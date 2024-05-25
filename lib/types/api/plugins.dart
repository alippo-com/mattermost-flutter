// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class ClientPluginManifest {
  final String id;
  final String? minServerVersion;
  final String version;
  final WebApp webapp;

  ClientPluginManifest({
    required this.id,
    this.minServerVersion,
    required this.version,
    required this.webapp,
  });
}

class WebApp {
  final String bundlePath;

  WebApp({
    required this.bundlePath,
  });
}

class MarketplacePlugin {
  final String homepageUrl;
  final String downloadUrl;
  final Manifest manifest;
  final String installedVersion;

  MarketplacePlugin({
    required this.homepageUrl,
    required this.downloadUrl,
    required this.manifest,
    required this.installedVersion,
  });
}

class Manifest {
  final String id;
  final String name;
  final String description;
  final String version;
  final String minServerVersion;

  Manifest({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.minServerVersion,
  });
}
