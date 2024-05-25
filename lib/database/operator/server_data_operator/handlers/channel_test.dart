    test('=> HandleChannelMembership: should write to the CHANNEL_MEMBERSHIP table', () async {
      expect.assertions(2);
      final channelMemberships = [
        ChannelMembership(
          id: '17bfnb1uwb8epewp4q3x3rx9go-9ciscaqbrpd6d8s68k76xb9bte',
          channelId: '17bfnb1uwb8epewp4q3x3rx9go',
          userId: '9ciscaqbrpd6d8s68k76xb9bte',
          roles: 'wqyby5r5pinxxdqhoaomtacdhc',
          lastViewedAt: 1613667352029,
          msgCount: 3864,
          mentionCount: 0,
          notifyProps: NotifyProps(
            desktop: 'default',
            email: 'default',
            ignoreChannelMentions: 'default',
            markUnread: 'mention',
            push: 'default',
          ),
          lastUpdateAt: 1613667352029,
          schemeUser: true,
          schemeAdmin: false,
        ),
        ChannelMembership(
          id: '1yw6gxfr4bn1jbyp9nr7d53yew-9ciscaqbrpd6d8s68k76xb9bte',
          channelId: '1yw6gxfr4bn1jbyp9nr7d53yew',
          userId: '9ciscaqbrpd6d8s68k76xb9bte',
          roles: 'channel_user',
          lastViewedAt: 1615300540549,
          msgCount: 16,
          mentionCount: 0,
          notifyProps: NotifyProps(
            desktop: 'default',
            email: 'default',
            ignoreChannelMentions: 'default',
            markUnread: 'all',
            push: 'default',
          ),
          lastUpdateAt: 1615300540549,
          schemeUser: true,
          schemeAdmin: false,
        ),
      ];

      final spyOnHandleRecords = spyOn(operator, 'handleRecords');

      await operator.handleChannelMembership(
        channelMemberships: channelMemberships,
        prepareRecordsOnly: false,
      );

      expect(spyOnHandleRecords).toHaveBeenCalledTimes(1);
      expect(spyOnHandleRecords).toHaveBeenCalledWith(
        {
          'fieldName': 'user_id',
          'createOrUpdateRawValues': channelMemberships,
          'tableName': 'ChannelMembership',
          'prepareRecordsOnly': false,
          'buildKeyRecordBy': buildChannelMembershipKey,
          'transformer': transformChannelMembershipRecord,
        },
        'handleChannelMembership',
      );
    });
  });
}
