import 'dart:math';

import 'package:flutter/material.dart';

class Generator {
  static const Color starColor = Color(0xfff9c700);
  static const Color goldColor = Color(0xffFFDF00);
  static const Color silverColor = Color(0xffC0C0C0);

  static const String _emojiText =
      "😀 😃 😄 😁 😆 😅 😂 🤣 😍 🥰 😘 😠 😡 💩 👻 🧐 🤓 😎 😋 😛 😝 😜 😢 😭 😤 🥱 😴 😾";

  static String randomString(int length) {
    var rand = Random();
    var codeUnits = List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });

    return String.fromCharCodes(codeUnits);
  }

  static String getTextFromSeconds(
      {int time = 0,
      bool withZeros = true,
      bool withHours = true,
      bool withMinutes = true,
      bool withSpace = true}) {
    int hour = (time / 3600).floor();
    int minute = ((time - 3600 * hour) / 60).floor();
    int second = (time - 3600 * hour - 60 * minute);

    String timeText = "";

    if (withHours && hour != 0) {
      if (hour < 10 && withZeros) {
        timeText += "0$hour${withSpace ? " : " : ":"}";
      } else {
        timeText += hour.toString() + (withSpace ? " : " : "");
      }
    }

    if (withMinutes) {
      if (minute < 10 && withZeros) {
        timeText += "0$minute${withSpace ? " : " : ":"}";
      } else {
        timeText += minute.toString() + (withSpace ? " : " : "");
      }
    }

    if (second < 10 && withZeros) {
      timeText += "0$second";
    } else {
      timeText += second.toString();
    }

    return timeText;
  }

  static Widget buildOverlaysProfile(
      {double size = 50,
      required List<String> images,
      bool enabledOverlayBorder = false,
      Color overlayBorderColor = Colors.white,
      double overlayBorderThickness = 1,
      double leftFraction = 0.7,
      double topFraction = 0}) {
    double leftPlusSize = size * leftFraction;
    double topPlusSize = size * topFraction;
    double leftPosition = 0;
    double topPosition = 0;

    List<Widget> list = [];
    for (int i = 0; i < images.length; i++) {
      if (i == 0) {
        list.add(
          Container(
            decoration: enabledOverlayBorder
                ? BoxDecoration(
                    border: Border.all(
                        color: Colors.transparent,
                        width: overlayBorderThickness),
                    shape: BoxShape.circle)
                : BoxDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(size / 2)),
              child: Image(
                image: AssetImage(images[i]),
                height: size,
                width: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      } else {
        leftPosition += leftPlusSize;
        topPosition += topPlusSize;
        list.add(Positioned(
          left: leftPosition,
          top: topPosition,
          child: Container(
            decoration: enabledOverlayBorder
                ? BoxDecoration(
                    border: Border.all(
                        color: overlayBorderColor,
                        width: overlayBorderThickness),
                    shape: BoxShape.circle)
                : BoxDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(size / 2)),
              child: Image(
                image: AssetImage(images[i]),
                height: size,
                width: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
      }
    }
    double width =
        leftPosition + size + ((images.length) * overlayBorderThickness);
    double height =
        topPosition + size + ((images.length) * overlayBorderThickness);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(clipBehavior: Clip.none, children: list),
    );
  }
}
