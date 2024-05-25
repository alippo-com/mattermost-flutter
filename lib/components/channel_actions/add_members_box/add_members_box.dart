
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:rxdart/rxdart.dart';

class AddMembersBox extends StatelessWidget {
  final String channelId;

  AddMembersBox({required this.channelId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    final channelDao = database.channelDao;

    Stream<String?> displayName = channelDao.getChannelById(channelId).asStream().switchMap((channel) {
      return Stream.value(channel?.displayName);
    });

    return StreamBuilder<String?>(
      stream: displayName,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final name = snapshot.data ?? 'Unknown Channel';
        return Text(name);
      },
    );
  }
}

class AddMembersBoxWrapper extends StatelessWidget {
  final String channelId;

  AddMembersBoxWrapper({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>(
      create: (_) => AppDatabase(),
      child: AddMembersBox(channelId: channelId),
    );
  }
}
