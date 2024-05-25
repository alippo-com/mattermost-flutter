import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/gutter.dart';
import 'package:mattermost_flutter/types.dart';

class RenderPageProps {
  final int index;
  final List<GlobalKey> pagerRefs;
  final void Function(bool) onPageStateChange;
  final GalleryItemType item;
  final double width;
  final double height;
  final bool isPageActive;
  final bool isPagerInProgress;

  RenderPageProps({
    required this.index,
    required this.pagerRefs,
    required this.onPageStateChange,
    required this.item,
    required this.width,
    required this.height,
    required this.isPageActive,
    required this.isPagerInProgress,
  });
}

class PageProps {
  final GalleryItemType item;
  final List<GlobalKey> pagerRefs;
  final void Function(bool) onPageStateChange;
  final double gutterWidth;
  final int index;
  final int length;
  final Widget Function(RenderPageProps, int) renderPage;
  final bool shouldRenderGutter;
  final double Function(int, [double?]) getPageTranslate;
  final double width;
  final double height;
  final int currentIndex;
  final bool isPagerInProgress;

  PageProps({
    required this.item,
    required this.pagerRefs,
    required this.onPageStateChange,
    required this.gutterWidth,
    required this.index,
    required this.length,
    required this.renderPage,
    required this.shouldRenderGutter,
    required this.getPageTranslate,
    required this.width,
    required this.height,
    required this.currentIndex,
    required this.isPagerInProgress,
  });
}

class Page extends StatefulWidget {
  final PageProps props;

  const Page({Key? key, required this.props}) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  late bool isPageActive;

  @override
  void initState() {
    super.initState();
    isPageActive = widget.props.currentIndex == widget.props.index;
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final containerStyle = [
      Positioned(
        left: -props.getPageTranslate(props.index, props.width),
        top: 0,
        bottom: 0,
        child: Container(
          width: props.width,
          child: Center(
            child: props.renderPage(
              RenderPageProps(
                index: props.index,
                pagerRefs: props.pagerRefs,
                onPageStateChange: props.onPageStateChange,
                item: props.item,
                width: props.width,
                height: props.height,
                isPageActive: isPageActive,
                isPagerInProgress: props.isPagerInProgress,
              ),
              props.index,
            ),
          ),
        ),
      ),
    ];

    return Stack(
      children: [
        ...containerStyle,
        if (props.index != props.length - 1 && props.shouldRenderGutter)
          Positioned(
            left: props.width,
            child: Gutter(width: props.gutterWidth),
          ),
      ],
    );
  }
}
