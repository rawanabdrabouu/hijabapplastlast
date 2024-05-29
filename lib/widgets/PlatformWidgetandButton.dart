import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PlatformWidget extends StatelessWidget {
  final Widget iosChild;
  final Widget androidChild;

  PlatformWidget({required this.iosChild, required this.androidChild});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return iosChild;
    } else {
      return androidChild;
    }
  }
}

class PlatformButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  PlatformButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        child: Text(text),
        onPressed: onPressed,
        color: CupertinoColors.activeBlue,
      );
    } else {
      return ElevatedButton(
        child: Text(text),
        onPressed: onPressed,
      );
    }
  }
}
