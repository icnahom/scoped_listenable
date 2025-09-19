library scoped_listenable;

import 'package:flutter/widgets.dart';

/// Provides a [Listenable] to decendant widgets.
class ScopedListenable<T extends Listenable> extends InheritedNotifier<T> {
  const ScopedListenable({super.key, required T? listenable, required super.child}) : super(notifier: listenable);

  /// Returns a [Listenable], or throws an error.
  static T of<T extends Listenable>(BuildContext context, {bool listen = true}) {
    final scopedListenable = listen
        ? context.dependOnInheritedWidgetOfExactType<ScopedListenable<T>>()
        : context.getElementForInheritedWidgetOfExactType<ScopedListenable<T>>()?.widget as ScopedListenable<T>?;

    if (scopedListenable == null) throw ScopedListenableNotFoundError();
    return scopedListenable.notifier!;
  }

  /// Returns a [ScopedListenableFactory] closure to be used in [ScopedContainer].
  static ScopedListenableFactory from<T extends Listenable>(T listenable, {Key? key}) {
    return (Widget child) {
      return ScopedListenable<T>(key: key, listenable: listenable, child: child);
    };
  }

  static ScopedListenableFactory builder<T extends Listenable>(
      ScopedListenable<T> Function(BuildContext context, Widget child) builder) {
    return (Widget child) {
      return Builder(
        builder: (context) {
          return builder(context, child);
        },
      );
    };
  }
}

/// Builds itself whenever [Listenable] of type [T] changes.
class ScopedBuilder<T extends Listenable> extends StatelessWidget {
  const ScopedBuilder({super.key, required this.builder, this.child});
  final Widget Function(BuildContext context, T listenable, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, ScopedListenable.of<T>(context), child);
  }
}

/// Provides all the [ScopedListenable]s to decendant widgets.
class ScopedContainer extends StatelessWidget {
  const ScopedContainer({super.key, required this.container, required this.child});
  final List<ScopedListenableFactory> container;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget currentChild = child;
    for (final scopedListenableFactory in container) {
      currentChild = scopedListenableFactory(currentChild);
      // assert(currentChild is ScopedListenable);
    }
    return currentChild;
  }
}

/// Lexical closure that creates and returns a [ScopedListenable] widget.
typedef ScopedListenableFactory = Widget Function(Widget child);

/// Methods for calling [ScopedListenable.of] on [BuildContext].
extension ScopedContext on BuildContext {
  /// Returns a [Listenable] without rebuilding on change.
  T get<T extends Listenable>() => ScopedListenable.of<T>(this, listen: false);

  /// Returns a [Listenable] and rebuilds on change.
  T watch<T extends Listenable>() => ScopedListenable.of<T>(this);
}

extension ScopedExtension<T extends ChangeNotifier> on T {
  ScopedListenableFactory scoped({Key? key}) {
    return ScopedListenable.from<T>(this, key: key);
  }
}

/// Error thrown whenever a [ScopedListenable] is not found.
class ScopedListenableNotFoundError<T> extends Error {
  @override
  String toString() {
    return '''
      Could not find ScopedListenable<$T> in the widget tree.

      * Make sure you have wrapped your widget with a ScopedListenable<$T> or a ScopedContainer.
      * If using a ScopedContainer, ensure the ScopedListenableFactory for type $T is included in the container list.
      ''';
  }
}
