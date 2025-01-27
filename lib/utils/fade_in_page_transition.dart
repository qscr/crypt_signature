import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRoute<T> {
  FadePageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  })  : assert(maintainState != null),
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => '';

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is FadePageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is FadePageRoute && !nextRoute.fullscreenDialog;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _FadeInPageTransition(routeAnimation: animation, child: child);
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

class _FadeInPageTransition extends StatelessWidget {
  _FadeInPageTransition({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  : _opacityAnimation = routeAnimation.drive(_easeInTween),
        super(key: key);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  final Animation<double> _opacityAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: child,
    );
  }
}
