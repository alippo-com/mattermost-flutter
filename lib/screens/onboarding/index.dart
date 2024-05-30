import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:mattermost_flutter/actions/app/global.dart';
import 'package:mattermost_flutter/screens/background.dart';

import 'footer_buttons.dart';
import 'paginator.dart';
import 'slide.dart';

class OnboardingProps {
  final ThemeData theme;

  OnboardingProps({required this.theme});
}

class Onboarding extends StatefulWidget {
  final OnboardingProps props;

  Onboarding({required this.props});

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late double width;
  late List slidesData;
  late ScrollController scrollController;
  late ValueNotifier<double> scrollX;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    width = MediaQuery.of(context).size.width;
    slidesData = useSlidesData();
    scrollController = ScrollController();
    scrollX = ValueNotifier(0.0);
    currentIndex = 0;

    scrollController.addListener(() {
      scrollX.value = scrollController.offset;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add any additional initialization logic here
    });

    SystemChannels.platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'SystemNavigator.pop') {
        if (currentIndex > 0) {
          moveToSlide(currentIndex - 1);
          return Future.value(true);
        }
      }
      return Future.value(false);
    });
  }

  void moveToSlide(int slideIndexToMove) {
    scrollController.animateTo(
      slideIndexToMove * width,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void signInHandler() {
    storeOnboardingViewedValue();
    goToScreen(Screens.SERVER, '', {'animated': true, 'theme': widget.props.theme}, loginAnimationOptions());
  }

  void nextSlide() {
    int nextSlideIndex = currentIndex + 1;
    if (currentIndex < slidesData.length - 1) {
      moveToSlide(nextSlideIndex);
    } else {
      signInHandler();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(theme: widget.props.theme),
          SafeArea(
            child: AnimatedBuilder(
              animation: scrollX,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-scrollX.value, 0),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: slidesData.length,
                      itemBuilder: (context, index) {
                        return SlideItem(
                          item: slidesData[index],
                          theme: widget.props.theme,
                          scrollX: scrollX,
                          index: index,
                          lastSlideIndex: slidesData.length - 1,
                        );
                      },
                    ),
                  ),
                  Paginator(
                    dataLength: slidesData.length,
                    theme: widget.props.theme,
                    scrollX: scrollX,
                    moveToSlide: moveToSlide,
                  ),
                  FooterButtons(
                    theme: widget.props.theme,
                    nextSlideHandler: nextSlide,
                    signInHandler: signInHandler,
                    scrollX: scrollX,
                    lastSlideIndex: slidesData.length - 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
