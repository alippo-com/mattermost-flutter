        {
          'name': 'should match permalink',
          'input': {
            'url': SITE_URL + '/ad-1/pl/qe93kkfd7783iqwuwfcwcxbsgy',
            'serverURL': SERVER_URL,
            'siteURL': SITE_URL,
          },
          'expected': {
            'data': {
              'postId': 'qe93kkfd7783iqwuwfcwcxbsgy',
              'serverUrl': URL_NO_PROTOCOL,
              'teamName': 'ad-1',
            },
            'type': DeepLinkType.Permalink,
          },
        },
        {
          'name': 'should match channel link with deeplink prefix',
          'input': {
            'url': DEEPLINK_URL_ROOT + '/ad-1/channels/town-square',
            'serverURL': SERVER_URL,
            'siteURL': SITE_URL,
          },
          'expected': {
            'data': {
              'channelName': 'town-square',
              'serverUrl': URL_NO_PROTOCOL,
              'teamName': 'ad-1',
            },
            'type': DeepLinkType.Channel,
          },
        },
        {
          'name': 'should match channel link (channel name: messages) with deeplink prefix',
          'input': {
            'url': DEEPLINK_URL_ROOT + '/ad-1/channels/messages',
            'serverURL': SERVER_URL,
            'siteURL': SITE_URL,
          },
          'expected': {
            'data': {
              'channelName': 'messages',
              'serverUrl': URL NO_PROTOCOL,
              'teamName': 'ad-1',
            },
            'type': DeepLinkType.Channel,
          },
        },
        {
          'name': 'should match DM channel link with deeplink prefix',
          'input': {
            'url': DEEPLINK_URL_ROOT + '/pl/messages/@${DM_USER.username}',
            'serverURL': SERVER_URL,
            'siteURL': SITE_URL,
          },
          'expected': {
            'data': {
              'userName': DM_USER.username,
              'serverUrl': URL NO_PROTOCOL,
              'teamName': 'pl',
            },
            'type': DeepLinkType.DirectMessage,
          },
        },
        {
          'name': 'should match GM channel link with deeplink prefix',
          'input': {
            'url': DEEPLINK_URL_ROOT + '/pl/messages/$GM_CHANNEL_NAME',
            'serverURL': SERVER URL,
            'siteURL': SITE URL,
          },
          'expected': {
            'data': {
              'channelName': GM_CHANNEL NAME,
              'serverUrl': URL NO PROTOCOL,
              'teamName': 'pl',
            },
            'type': DeepLinkType.GroupMessage,
          },
        },
        {
          'name': 'should match channel link (team name: pl, channel name: messages) with deeplink prefix',
          'input': {
            'url': DEEPLINK_URL_ROOT + '/pl/channels/messages',
            'serverURL': SERVER URL,
            'siteURL': SITE URL,
          },
          'expected': {
            'data': {
              'channelName': 'messages',
              'serverUrl': URL NO PROTOCOL,
              'teamName': 'pl',
            },
            'type': DeepLinkType.Channel,
          },
        },
        {
          'name': 'should match permalink with deeplink prefix on a Server hosted in a Subpath',
          'input': {
            'url': DEEPLINK URL ROOT + '/subpath/deepsubpath/ad-1/pl/qe93kkfd7783iqwuwfcwcxbsrr',
            'serverURL': SERVER WITH SUBPATH,
            'siteURL': SERVER WITH SUBPATH,
          },
          'expected': {
            'data': {
              'postId': 'qe93kkfd7783iqwuwfcwcxbsrr',
              'serverUrl': URL PATH NO PROTOCOL,
              'teamName': 'ad-1',
            },
            'type': DeepLinkType Permalink,
          },
        },
        {
          'name': 'should match permalink (team name: pl) with deeplink prefix on a Server hosted in a Subpath',
          'input': {
            'url': DEEPLINK URL ROOT + '/subpath/deepsubpath/pl/pl/qe93kkfd7783iqwuwfcwcxbsrr',
            'serverURL': SERVER WITH SUBPATH,
            'siteURL': SERVER WITH SUBPATH,
          },
          'expected': {
            'data': {
              'postId': 'qe93kkfd7783iqwuwfcwcxbsrr',
              'serverUrl': URL PATH NO PROTOCOL,
              'teamName': 'pl',
            },
            'type': DeepLinkType Permalink,
          },
        },
        {
          'name': 'should match permalink on a Server hosted in a Subpath',
          'input': {
            'url': SERVER WITH SUBPATH + '/ad-1/pl/qe93kkfd7783iqwuwfcwcxbsrr',
            'serverURL': SERVER WITH SUBPATH,
            'siteURL': SERVER WITH SUBPATH,
          },
          'expected': {
            'data': {
              'postId': 'qe93kkfd7783iqwuwfcwcxbsrr',
              'serverUrl': URL PATH NO PROTOCOL,
              'teamName': 'ad-1',
            },
            'type': DeepLinkType Permalink,
          },
        },
        {
          'name': 'should not match url',
          'input': {
            'url': 'https://github.com/mattermost/mattermost-mobile/issues/new',
            'serverURL': SERVER WITH SUBPATH,
            'siteURL': SERVER WITH SUBPATH,
          },
          'expected': null,
        },
        {
          'name': 'should not match plugin path',
          'input': {
            'url': DEEPLINK URL ROOT + '/subpath/deepsubpath/plugins/abc/api/testroute',
            'serverURL': SERVER WITH SUBPATH,
            'siteURL': SERVER WITH SUBPATH,
          },
          'expected': null,
        },
      ];

      for (var test in tests) {
        final name = test['name'];
        final input = test['input'];
        final expected = test['expected'];

        test(name!, () {
          final matched = matchDeepLink(input!['url']!, input['serverURL']!, input['siteURL']!);
          if (matched != null) {
            matched.remove('url');
          }
          expect(matched, equals(expected));
        });
      }
    });

    group('tryOpenUrl', () {
      const url = 'https://some.url.com';

      test('should call onSuccess when Linking.openURL succeeds', () async {
        // Mocked success response
        final onSuccess = () {};
        final onError = () {};

        await UrlUtils.tryOpenURL(url, onError, onSuccess);
        // Add your expectations here
      });

      test('should call onError when Linking.openURL fails', () async {
        // Mocked failure response
        final onSuccess = () {};
        final onError = () {};

        await UrlUtils.tryOpenURL(url, onError, onSuccess);
        // Add your expectations here
      });
    });
  });
}
