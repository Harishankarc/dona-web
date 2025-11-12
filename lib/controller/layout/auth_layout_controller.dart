import 'dart:async';

import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:flutter/material.dart';

class AuthLayoutController extends MyController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final scrollKey = GlobalKey();

  int animatedCarouselSize = 3;
  int selectedAnimatedCarousel = 0;
  final PageController animatedPageController = PageController(initialPage: 0);
  Timer? timerAnimation;

  @override
  void onInit() {
    timerAnimation = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (selectedAnimatedCarousel < animatedCarouselSize - 1) {
        selectedAnimatedCarousel++;
      } else {
        selectedAnimatedCarousel = 0;
      }
      if (animatedPageController.hasClients) {
        animatedPageController.animateToPage(
          selectedAnimatedCarousel,
          duration: const Duration(milliseconds: 600),
          curve: Curves.ease,
        );
      }
      update();
    });
    super.onInit();
  }

  void onChangeAnimatedCarousel(int value) {
    selectedAnimatedCarousel = value;
    update();
  }
}
