library scoped_listenable;

import 'package:flutter/widgets.dart';

/// Provides a [Listenable] to decendant widgets.
class ScopedListenable<T extends Listenable> extends InheritedNotifier<T> {
  const ScopedListenable({super.key, required T? listenable, required super.child}) : super(notifier: listenable);

  /// Returns a [Listenable], or throws an error.
  static T of<T extends Listenable>(BuildContext context, {bool listen = true}) {
    ScopedListenable<T>? widget = listen
        ? context.dependOnInheritedWidgetOfExactType() //
        : context.getInheritedWidgetOfExactType();

    if (widget?.notifier case T notifier) return notifier;
    throw ScopedListenableNotFoundError<T>();
  }

  /// Returns a [ScopedFactory] lexical closure to be used in [ScopedListenable.merge].
  static ScopedFactory from<T extends Listenable>(T listenable, {Key? key}) {
    return (Widget child) => ScopedListenable<T>(key: key, listenable: listenable, child: child);
  }

  /// Merges multiple [ScopedFactory] into a single widget tree.
  static Widget merge({required List<ScopedFactory> listenables, required Widget child}) =>
      listenables.reversed.fold(child, (currentChild, scopedFactory) => scopedFactory(currentChild));
}

/// Builds itself whenever [Listenable] of type [T] changes.
class ScopedBuilder<T extends Listenable> extends StatelessWidget {
  const ScopedBuilder({super.key, required this.builder, this.child});
  final Widget Function(BuildContext context, T listenable, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, context.watch<T>(), child);
  }
}

/// Methods for calling [ScopedListenable.of] on [BuildContext].
extension ScopedContext on BuildContext {
  /// Returns a [Listenable] without rebuilding on change.
  T read<T extends Listenable>() => ScopedListenable.of<T>(this, listen: false);

  /// Returns a [Listenable] and rebuilds on change.
  T watch<T extends Listenable>() => ScopedListenable.of<T>(this);
}

/// Methods for creating a [ScopedFactory] from a [ChangeNotifier].
extension ScopedExtension<T extends ChangeNotifier> on T {
  ScopedFactory scoped({Key? key}) => ScopedListenable.from<T>(this, key: key);
}

/// Lexical closure that creates and returns a [ScopedListenable] widget.
typedef ScopedFactory = Widget Function(Widget child);

/// Error thrown whenever a [ScopedListenable] is not found.
class ScopedListenableNotFoundError<T> extends Error {
  @override
  String toString() {
    return '''
      Could not find a `ScopedListenable<$T>` in the widget tree.

      To fix:
      * Wrap your widget subtree with `ScopedListenable<$T>` or include it in a `ScopedListenable.merge`.
      * If navigating routes, ensure the `ScopedListenable` is above the shared Navigator.
      ''';
  }
}
