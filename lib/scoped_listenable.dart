library scoped_listenable;

import 'package:flutter/widgets.dart';

/// Provides a [Listenable] to decendant widgets.
class ScopedListenable<T extends Listenable> extends InheritedNotifier<T> {
  const ScopedListenable(
      {super.key, required T? listenable, required super.child})
      : super(notifier: listenable);

  /// Returns a [Listenable], or throws an error.
  static T of<T extends Listenable>(BuildContext context,
      {bool rebuildOnChange = true}) {
    final scopedListenable = rebuildOnChange
        ? context.dependOnInheritedWidgetOfExactType<ScopedListenable<T>>()
        : context
            .getElementForInheritedWidgetOfExactType<ScopedListenable<T>>()
            ?.widget as ScopedListenable<T>?;
    if (scopedListenable == null) {
      throw ScopedError<T>();
    }
    return scopedListenable.notifier!;
  }

  /// Returns a [ScopedListenableFactory] closure to be used in [ScopedContainer].
  static ScopedListenableFactory from<T extends Listenable>(T listenable,
      {Key? key}) {
    return (BuildContext context, Widget child) {
      return ScopedListenable<T>(
          key: key, listenable: listenable, child: child);
    };
  }
}

/// Builds itself whenever [Listenable] of type [T] changes.
class ScopedBuilder<T extends Listenable> extends StatelessWidget {
  const ScopedBuilder({super.key, required this.builder, this.child});
  final Widget Function(BuildContext context, T listenable, Widget? child)
      builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, ScopedListenable.of<T>(context), child);
  }
}

/// Provides all the [ScopedListenable]s to decendant widgets.
class ScopedContainer extends StatelessWidget {
  const ScopedContainer(
      {super.key, required this.container, required this.child});
  final List<ScopedListenableFactory> container;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget currentChild = child;
    for (final scopedListenableFactory in container) {
      currentChild = scopedListenableFactory(context, currentChild);
      assert(currentChild is ScopedListenable);
    }
    return currentChild;
  }
}

/// Closure that creates and returns a [ScopedListenable] widget.
typedef ScopedListenableFactory = Widget Function(
    BuildContext context, Widget child);

/// Methods for calling [ScopedListenable.of] on [BuildContext].
extension ScopedContext on BuildContext {
  /// Returns a [Listenable] without rebuilding on change.
  T get<T extends Listenable>() {
    return ScopedListenable.of<T>(this, rebuildOnChange: false);
  }

  /// Returns a [Listenable] and rebuilds on change.
  T watch<T extends Listenable>() {
    return ScopedListenable.of<T>(this);
  }
}

/// Error thrown whenever a [ScopedListenable] is not found.
class ScopedError<T> extends Error {
  @override
  String toString() {
    return '''
      Error: Could not find ScopedListenable<$T>.
      
      To fix, please:
                
        * Provide type to ScopedBuilder<MyListenable> 
        * Provide ScopedListenable<MyListenable> above MaterialApp or Navigator         
        
      If none of these solutions work, please file a bug at:
      https://github.com/icnahom/scoped_listenable/issues/new
    ''';
  }
}
