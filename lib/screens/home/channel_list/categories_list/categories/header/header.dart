
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reaction/flutter_reaction.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/categories.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/actions/local/category.dart';
import 'package:mattermost_flutter/typings/database/models/servers/category.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryHeader extends HookWidget {
  final CategoryModel category;
  final bool hasChannels;

  CategoryHeader({
    required this.category,
    required this.hasChannels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final serverUrl = useServerUrl();
    final collapsed = useState(category.collapsed);

    void toggleCollapse() {
      toggleCollapseCategory(serverUrl, category.id);
    }

    final rotate = useAnimationController(duration: Duration(milliseconds: 100));
    final animation = useDerivedValue(() {
      return withTiming(collapsed.value ? -90.0 : 0.0);
    });

    useEffect(() {
      collapsed.value = category.collapsed;
    }, [category.collapsed]);

    // Hide favs if empty
    if (!hasChannels && category.type == FAVORITES_CATEGORY) {
      return Container();
    }

    String displayName = category.displayName;
    switch (category.type) {
      case FAVORITES_CATEGORY:
        displayName = 'Favorites';
        break;
      case CHANNELS_CATEGORY:
        displayName = 'Channels';
        break;
      case DMS_CATEGORY:
        displayName = 'Direct messages';
        break;
    }

    return GestureDetector(
      onTap: toggleCollapse,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        margin: EdgeInsets.only(top: 12, left: 16),
        decoration: BoxDecoration(
          color: theme.sidebarBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: animation.value,
                  child: CompassIcon(
                    name: 'chevron-down',
                    size: 20,
                    color: changeOpacity(theme.sidebarText, 0.64),
                  ),
                );
              },
            ),
            SizedBox(width: 8),
            Text(
              displayName,
              style: TextStyle(
                color: changeOpacity(theme.sidebarText, 0.64),
                textTransform: TextTransform.uppercase,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        padding: EdgeInsets.symmetric(vertical: 8),
        margin: EdgeInsets.only(top: 12, left: 16),
        color: theme.sidebarBg,
        borderRadius: BorderRadius.circular(4),
      ),
      'heading': TextStyle(
        color: changeOpacity(theme.sidebarText, 0.64),
        textTransform: TextTransform.uppercase,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      'chevron': BoxDecoration(
        color: changeOpacity(theme.sidebarText, 0.64),
        width: 20,
        height: 20,
      ),
      'muted': BoxDecoration(
        opacity: 0.32,
      ),
    };
  }
}
