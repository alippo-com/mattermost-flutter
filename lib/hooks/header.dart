
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reanimated/reanimated.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/i18n.dart';

const MAX_OVERSCROLL = 80.0;

double useDefaultHeaderHeight(BuildContext context) {
  final insets = MediaQuery.of(context).padding;
  final isTablet = useIsTablet(context);

  double headerHeight = ViewConstants.DEFAULT_HEADER_HEIGHT;
  if (isTablet) {
    headerHeight = ViewConstants.TABLET_HEADER_HEIGHT;
  }
  return headerHeight + insets.top;
}

double useLargeHeaderHeight(BuildContext context) {
  double largeHeight = useDefaultHeaderHeight(context);
  largeHeight += ViewConstants.LARGE_HEADER_TITLE_HEIGHT;
  largeHeight += ViewConstants.SUBTITLE_HEIGHT;
  return largeHeight;
}

Map<String, double> useHeaderHeight(BuildContext context) {
  final defaultHeight = useDefaultHeaderHeight(context);
  final largeHeight = useLargeHeaderHeight(context);
  final headerOffset = largeHeight - defaultHeight;
  return {
    'defaultHeight': defaultHeight,
    'largeHeight': largeHeight,
    'headerOffset': headerOffset,
  };
}

class CollapsibleHeader {
  final double defaultHeight;
  final double largeHeight;
  final double scrollPaddingTop;
  final ValueNotifier<double> scrollValue;
  final ValueNotifier<double?> lockValue = ValueNotifier<double?>(null);
  final ValueNotifier<bool> autoScroll = ValueNotifier<bool>(false);
  final ValueNotifier<bool> snapping = ValueNotifier<bool>(false);
  final ValueNotifier<bool> scrollEnabled = ValueNotifier<bool>(true);
  final Function(String, double)? onSnap;
  final ScrollController scrollController = ScrollController();

  CollapsibleHeader(
    BuildContext context,
    bool isLargeTitle, {
    this.onSnap,
  })  : defaultHeight = useDefaultHeaderHeight(context),
        largeHeight = useLargeHeaderHeight(context),
        scrollPaddingTop = isLargeTitle ? useLargeHeaderHeight(context) : useDefaultHeaderHeight(context),
        scrollValue = ValueNotifier<double>(0);

  double get headerOffset => largeHeight - defaultHeight;

  double get headerHeight {
    final value = -(scrollValue.value);
    final heightWithScroll = (scrollPaddingTop) + value;
    double height = heightWithScroll.clamp(defaultHeight, largeHeight + MAX_OVERSCROLL);
    return height;
  }

  void snapIfNeeded(String dir, double offset) {
    if (onSnap != null && !snapping.value) {
      snapping.value = true;
      if (dir == 'down' && offset < largeHeight) {
        onSnap!(0, offset);
      } else if (dir == 'up' && offset < defaultHeight) {
        onSnap!(headerOffset, offset);
      }
      snapping.value = false;
    }
  }

  void setAutoScroll(bool enabled) {
    autoScroll.value = enabled;
  }

  void onScroll() {
    scrollController.addListener(() {
      if (!scrollEnabled.value) {
        scrollController.jumpTo(headerOffset);
        return;
      }

      if (autoScroll.value || snapping.value) {
        scrollValue.value = scrollController.offset;
      } else {
        scrollController.jumpTo(scrollValue.value);
      }
    });
  }

  void hideHeader([bool lock = false]) {
    if (lock) {
      lockValue.value = defaultHeight;
    }

    if (scrollController.positions.isNotEmpty && scrollController.offset <= MediaQuery.of(context).padding.top) {
      autoScroll.value = true;
      scrollController.animateTo(headerOffset, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void unlock() {
    lockValue.value = null;
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Collapsible Header Example'),
        ),
        body: CollapsibleHeaderExample(),
      ),
    );
  }
}

class CollapsibleHeaderExample extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final header = CollapsibleHeader(context, true, onSnap: (offset, _) => print('Snapped to $offset'));

    useEffect(() {
      header.onScroll();
      return;
    }, []);

    return ListView.builder(
      controller: header.scrollController,
      itemCount: 50,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
        );
      },
    );
  }
}
