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

  /// Returns a [ScopedFactory] lexical closure to be used in [ScopedContainer].
  static ScopedFactory from<T extends Listenable>(T listenable, {Key? key}) {
    return (Widget child) => ScopedListenable<T>(key: key, listenable: listenable, child: child);
  }

  static ScopedFactory builder<T extends Listenable>(
      ScopedListenable<T> Function(BuildContext context, Widget child) builder) {
    return (Widget child) => Builder(builder: (context) => builder(context, child));
  }
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

/// Provides all the [ScopedListenable]s to decendant widgets.
class ScopedContainer extends StatelessWidget {
  const ScopedContainer({super.key, required this.container, required this.child});
  final List<ScopedFactory> container;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return container.reversed.fold(child, (currentChild, scopedFactory) => scopedFactory(currentChild));
  }
}

/// Methods for calling [ScopedListenable.of] on [BuildContext].
extension ScopedContext on BuildContext {
  /// Returns a [Listenable] without rebuilding on change.
  T read<T extends Listenable>() => ScopedListenable.of<T>(this, listen: false);

  /// Returns a [Listenable] and rebuilds on change.
  T watch<T extends Listenable>() => ScopedListenable.of<T>(this);
}

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
      Could not find a ScopedListenable<$T> in the widget tree.

      To fix:
      * Wrap your widget subtree with ScopedListenable<$T> or include it in a ScopedContainer.
      * If navigating routes, ensure the ScopedListenable is above the shared Navigator.
      ''';
  }
}
