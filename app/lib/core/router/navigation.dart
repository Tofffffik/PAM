import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension BackNavigation on BuildContext {
  /// Back if there is somewhere to go back to, otherwise to [fallback].
  ///
  /// A screen opened straight from a link — a route shared in a chat, a
  /// refreshed browser tab — has nothing under it in the stack.
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}
