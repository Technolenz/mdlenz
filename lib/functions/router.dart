import 'package:flutter/material.dart';
import 'package:mdlenz/main.dart';
import 'package:page_transition/page_transition.dart';

void navigateTo({
  required BuildContext context,
  required Widget page,
  PageTransitionType transition = PageTransitionType.rightToLeft,
  Duration duration = const Duration(milliseconds: 300),
}) {
  Navigator.push(context, PageTransition(child: page, type: transition, duration: duration));
}

void authTransition({
  required BuildContext context,
  required Widget page,
  PageTransitionType transition = PageTransitionType.rightToLeft,
  Duration duration = const Duration(milliseconds: 300),
}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const MainScreen()),
    (route) => false,
  );
}
