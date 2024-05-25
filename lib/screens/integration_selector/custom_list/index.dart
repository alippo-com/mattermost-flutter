import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const int INITIAL_BATCH_TO_RENDER = 15;

typedef DataType = List<dynamic>;

class ListItemProps {
  final String id;
  final dynamic item;
  final bool selected;
  final bool selectable;
  final bool enabled;
  final Function(dynamic) onPress;

  ListItemProps({
    required this.id,
    required this.item,
    required this.selected,
    this.selectable = false,
    required this.enabled,
    required this.onPress,
  });
}

ThemeData getStyleFromTheme(ThemeData theme) {
  return theme.copyWith(
    // Custom styles
  );
}

class CustomList extends StatelessWidget {
  final DataType data;
  final bool shouldRenderSeparator;
  final bool loading;
  final Widget? loadingComponent;
  final Widget Function()? noResults;
  final void Function() onLoadMore;
  final void Function(dynamic) onRowPress;
  final bool selectable;
  final Widget Function(ListItemProps) renderItem;
  final ThemeData theme;
  final bool canRefresh;
  final String? testID;
  final bool refreshing;
  final void Function()? onRefresh;

  const CustomList({
    required this.data,
    required this.shouldRenderSeparator,
    required this.loading,
    this.loadingComponent,
    this.noResults,
    required this.onLoadMore,
    required this.onRowPress,
    required this.selectable,
    required this.renderItem,
    required this.theme,
    this.canRefresh = true,
    this.testID,
    this.refreshing = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleFromTheme(theme);

    Widget renderEmptyList() {
      return noResults?.call() ?? Container();
    }

    Widget renderSeparator() {
      if (!shouldRenderSeparator) {
        return Container();
      }
      return Container(
        height: 1,
        color: style.dividerColor,
      );
    }

    Widget renderListItem(BuildContext context, dynamic item) {
      final props = ListItemProps(
        id: item['key'],
        item: item,
        selected: item['selected'],
        selectable: selectable,
        enabled: !(item['disableSelect'] ?? false),
        onPress: onRowPress,
      );
      return renderItem(props);
    }

    Widget renderFooter() {
      if (!loading || loadingComponent == null) {
        return Container();
      }
      return loadingComponent!;
    }

    RefreshIndicator? refreshControl;
    if (canRefresh) {
      refreshControl = RefreshIndicator(
        onRefresh: () async => onRefresh?.call(),
        child: Container(),
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return renderListItem(context, data[index]);
      },
      separatorBuilder: (context, index) => renderSeparator(),
      padding: EdgeInsets.all(0),
      controller: ScrollController(),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }
}
