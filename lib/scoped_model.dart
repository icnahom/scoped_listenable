library scoped_model;

import 'package:flutter/widgets.dart';

/// Provides a [Listenable] to decendant widgets.
class ScopedModel<T extends Listenable> extends InheritedNotifier<T> {
  const ScopedModel({super.key, required T? model, required super.child})
      : super(notifier: model);

  /// Returns a [Listenable], or throws an error.
  static T of<T extends Listenable>(BuildContext context,
      {bool rebuildOnChange = true}) {
    final scopedModel = rebuildOnChange
        ? context.dependOnInheritedWidgetOfExactType<ScopedModel<T>>()
        : context
            .getElementForInheritedWidgetOfExactType<ScopedModel<T>>()
            ?.widget as ScopedModel<T>?;
    if (scopedModel == null) {
      throw ScopedError<T>();
    }
    return scopedModel.notifier!;
  }

  /// Returns a [ScopedModelFactory] closure to be used in [ScopedContainer].
  static ScopedModelFactory from<T extends Listenable>(T model, {Key? key}) {
    return (BuildContext context, Widget child) {
      return ScopedModel<T>(key: key, model: model, child: child);
    };
  }
}

/// Builds itself whenever [Listenable] of type [T] changes.
class ScopedBuilder<T extends Listenable> extends StatelessWidget {
  const ScopedBuilder({super.key, required this.builder, this.child});
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, ScopedModel.of<T>(context), child);
  }
}

/// Provides all the [ScopedModel]s to decendant widgets.
class ScopedContainer extends StatelessWidget {
  const ScopedContainer(
      {super.key, required this.container, required this.child});
  final List<ScopedModelFactory> container;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget currentChild = child;
    for (final scopedModelFactory in container) {
      currentChild = scopedModelFactory(context, currentChild);
      assert(currentChild is ScopedModel);
    }
    return currentChild;
  }
}

/// Closure that creates and returns a [ScopedModel] widget.
typedef ScopedModelFactory = Widget Function(
    BuildContext context, Widget child);

/// Methods for calling [ScopedModel.of] on [BuildContext].
extension ScopedContext on BuildContext {
  /// Returns a [Listenable] without rebuilding on change.
  T get<T extends Listenable>() {
    return ScopedModel.of<T>(this, rebuildOnChange: false);
  }

  /// Returns a [Listenable] and rebuilds on change.
  T observe<T extends Listenable>() {
    return ScopedModel.of<T>(this);
  }
}

/// Error thrown whenever a [ScopedModel] is not found.
class ScopedError<T> extends Error {
  @override
  String toString() {
    return '''
      Error: Could not find ScopedModel<$T>.
      
      To fix, please:
                
        * Provide type to ScopedBuilder<MyModel> 
        * Provide ScopedModel<MyModel> above MaterialApp or Navigator         
        
      If none of these solutions work, please file a bug at:
      https://github.com/icnahom/scoped_model/issues/new
    ''';
  }
}
