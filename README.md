<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Provides Listenable model to descendant widgets.

## Getting started

Add `scoped_model` as a [dependency](https://dart.dev/tools/pub/dependencies#git-packages). 
```yaml
scoped_model:
  git: https://github.com/icnahom/scoped_model.git
```

Import package: 
```dart 
import 'package:icnahom/scoped_model.dart'; 
```

## Usage

Provide a Listenable model to descendant widgets. 

```dart
ScopedModel(
  model: counterModel,
  child: MyApp(),
);
```

Observe changes in the Listenable provided by an ancestor widget.

```dart
ScopedBuilder<CounterModel>(
  builder: (context, model, child) {
    return Text('${model.counter}');
  },
);
```

### Advanced

To add multiple ScopedModels, use ScopedContainer. 

```dart
ScopedContainer(
  container: [
    ScopedModel.from(counterModel),
    ScopedModel.from(settingsModel),
  ],
  child: MyApp(),
);
```

To obtain Listenable directly, use extension methods. 

```dart
context.find<CounterModel>();

context.dependOn<CounterModel>();
```

## Additional information

This is a ported and maintained version of [scoped_model](https://github.com/brianegan/scoped_model). 

> All credits goes to the original authors and maintainers of the package.