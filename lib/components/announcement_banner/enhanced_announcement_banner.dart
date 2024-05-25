import 'package:flutter/material.dart';
import 'package:rx_dart/rx_dart.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/components/announcement_banner/announcement_banner.dart';

class EnhancedAnnouncementBanner extends StatelessWidget {
  final Database database;

  const EnhancedAnnouncementBanner({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lastDismissed = observeLastDismissedAnnouncement(database);
    final bannerText = observeConfigValue(database, 'BannerText');
    final allowDismissal = observeConfigBooleanValue(database, 'AllowBannerDismissal');

    final bannerDismissed = Rx.combineLatest3(
      lastDismissed,
      bannerText,
      allowDismissal,
      (ld, bt, abd) => abd && (ld == bt),
    );

    final license = observeLicense(database);
    final enableBannerConfig = observeConfigBooleanValue(database, 'EnableBanner');
    final bannerEnabled = Rx.combineLatest2(
      license,
      enableBannerConfig,
      (lcs, cfg) => cfg && lcs?.isLicensed == 'true',
    );

    return AnnouncementBanner(
      bannerColor: observeConfigValue(database, 'BannerColor'),
      bannerEnabled: bannerEnabled,
      bannerText: bannerText,
      bannerTextColor: observeConfigValue(database, 'BannerTextColor'),
      bannerDismissed: bannerDismissed,
      allowDismissal: allowDismissal,
    );
  }
}
