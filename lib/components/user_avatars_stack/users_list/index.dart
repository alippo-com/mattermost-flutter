import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/user_item.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/utils/alert.dart';
import 'package:mattermost_flutter/utils/dismiss_bottom_sheet.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/models/servers/user.dart';

class UserListItem extends StatelessWidget {
  final String channelId;
  final String location;
  final UserModel user;

  UserListItem({
    required this.channelId,
    required this.location,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Provider.of<Intl>(context);
    final theme = Provider.of<Theme>(context);

    void openUserProfile(UserModel user) async {
      await dismissBottomSheet(Screens.BOTTOM_SHEET);
      final screen = Screens.USER_PROFILE;
      final title = intl.formatMessage('mobile.routes.user_profile', defaultMessage: 'Profile');
      final closeButtonId = 'close-user-profile';
      final props = {'closeButtonId': closeButtonId, 'location': location, 'userId': user.id, 'channelId': channelId};

      SystemChannels.textInput.invokeMethod('TextInput.hide');
      openAsBottomSheet({'screen': screen, 'title': title, 'theme': theme, 'closeButtonId': closeButtonId, 'props': props});
    }

    return UserItem(
      user: user,
      onUserPress: () => openUserProfile(user),
    );
  }
}

class UsersList extends StatefulWidget {
  final String channelId;
  final String location;
  final String type;
  final List<UserModel> users;

  UsersList({
    required this.channelId,
    required this.location,
    this.type = 'FlatList',
    required this.users,
  });

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  bool enabled;
  String direction;
  ScrollController listController;
  double prevOffset;

  @override
  void initState() {
    super.initState();
    enabled = widget.type == 'BottomSheetFlatList';
    direction = 'down';
    listController = ScrollController();
    prevOffset = 0;
  }

  void onScroll() {
    if (listController.offset <= 0 && enabled && direction == 'down') {
      setState(() {
        enabled = false;
      });
      listController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    final dir = prevOffset < details.delta.dy ? 'down' : 'up';
    prevOffset = details.delta.dy;
    if (!enabled && dir == 'up') {
      setState(() {
        enabled = true;
      });
    }
    direction = dir;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'BottomSheetFlatList') {
      return ListView.builder(
        controller: listController,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return UserListItem(
            channelId: widget.channelId,
            location: widget.location,
            user: widget.users[index],
          );
        },
        physics: enabled ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      );
    }

    return GestureDetector(
      onPanUpdate: onPanUpdate,
      child: ListView.builder(
        controller: listController,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return UserListItem(
            channelId: widget.channelId,
            location: widget.location,
            user: widget.users[index],
          );
        },
        physics: enabled ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      ),
    );
  }
}
