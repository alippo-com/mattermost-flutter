// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types/onboarding.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:intl/intl.dart';

class Styles {
  static final image = BoxDecoration(
    color: Colors.transparent,
    // Other style properties as needed
  );

  static final lastSlideImage = BoxDecoration(
    color: Colors.transparent,
    // Other style properties as needed
  );
}

class CallsSvg extends StatelessWidget {
  final Decoration styles;
  final ThemeData theme;

  CallsSvg({required this.styles, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: styles,
      child: SvgPicture.asset(
        'assets/illustrations/calls.svg',
        color: theme.primaryColor,
      ),
    );
  }
}

class ChatSvg extends StatelessWidget {
  final Decoration styles;
  final ThemeData theme;

  ChatSvg({required this.styles, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: styles,
      child: SvgPicture.asset(
        'assets/illustrations/chat.svg',
        color: theme.primaryColor,
      ),
    );
  }
}

class TeamCommunicationSvg extends StatelessWidget {
  final Decoration styles;
  final ThemeData theme;

  TeamCommunicationSvg({required this.styles, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: styles,
      child: SvgPicture.asset(
        'assets/illustrations/team_communication.svg',
        color: theme.primaryColor,
      ),
    );
  }
}

class IntegrationsSvg extends StatelessWidget {
  final List<Decoration> styles;
  final ThemeData theme;

  IntegrationsSvg({required this.styles, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: styles.reduce((value, element) => value..addAll(element)),
      child: SvgPicture.asset(
        'assets/illustrations/integrations.svg',
        color: theme.primaryColor,
      ),
    );
  }
}

class UseSlidesData {
  final BuildContext context;

  UseSlidesData(this.context);

  List<OnboardingItem> get slidesData {
    final intl = Intl.of(context);
    final theme = Provider.of<ThemeNotifier>(context).theme;

    final callsSvg = CallsSvg(
      styles: Styles.image,
      theme: theme,
    );
    final chatSvg = ChatSvg(
      styles: Styles.image,
      theme: theme,
    );
    final teamCommunicationSvg = TeamCommunicationSvg(
      styles: Styles.image,
      theme: theme,
    );
    final integrationsSvg = IntegrationsSvg(
      styles: [Styles.image, Styles.lastSlideImage],
      theme: theme,
    );

    return [
      OnboardingItem(
        title: intl.message('onboarding.welcome', 'Welcome'),
        description: intl.message('onboaring.welcome_description', 'Mattermost is an open source platform for developer collaboration. Secure, flexible, and integrated with your tools.'),
        image: chatSvg,
      ),
      OnboardingItem(
        title: intl.message('onboarding.realtime_collaboration', 'Collaborate in real‑time'),
        description: intl.message('onboarding.realtime_collaboration_description', 'Persistent channels, direct messaging, and file sharing works seamlessly so you can stay connected, wherever you are.'),
        image: teamCommunicationSvg,
      ),
      OnboardingItem(
        title: intl.message('onboarding.calls', 'Start secure audio calls instantly'),
        description: intl.message('onboarding.calls_description', 'When typing isn’t fast enough, switch from channel-based chat to secure audio calls with a single tap.'),
        image: callsSvg,
      ),
      OnboardingItem(
        title: intl.message('onboarding.integrations', 'Integrate with tools you love'),
        description: intl.message('onboarding.integrations_description', 'Go beyond chat with tightly-integrated product solutions matched to common development processes.'),
        image: integrationsSvg,
      ),
    ];
  }
}
