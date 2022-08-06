import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AnimateRoute extends PageRouteBuilder{
  final Widget page;
  final Widget route;

  AnimateRoute({required this.page, required this.route}):super(
    pageBuilder: (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation
    )=>page,transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child
  )=>FadeTransition(opacity: animation,
      child: route,)
  );


}
Widget ripple( BuildContext context,Duration animationDuration,Rect? rect) {
 // var rect;

  return AnimatedPositioned(
    left: rect!.left,
    right: MediaQuery.of(context).size.width - rect.right,
    top: rect.top,
    bottom: MediaQuery.of(context).size.height - rect.bottom,
    duration: animationDuration,
    child: Container(                                         //<-- Blue cirle
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
    ),
  );
}
class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRouteBuilder({required this.page})
      : super(
    pageBuilder: (context, animation1, animation2) => page,
    transitionsBuilder: (context, animation1, animation2, child) {
      return FadeTransition(opacity: animation1, child: child);
    },
  );
}
