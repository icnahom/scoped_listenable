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

## Getting started

Add `scoped_listenable` as a dependency in your `pubspec.yaml` file.

## Usage

Provide a Listenable to descendant widgets. 

```dart
ScopedListenable(
  listenable: counterModel,
  child: MyApp(),
);
```

Observe changes in the Listenable provided by an ancestor widget.

```dart
ScopedBuilder<CounterModel>(
  builder: (context, listenable, child) {
    return Text('${listenable.counter}');
  },
);
```

### Advanced

To add multiple ScopedListenables, use ScopedContainer. 

```dart
ScopedContainer(
  container: [
    ScopedListenable.from(counterModel),
    // Or
    counterModel.scoped(),
    // Or
    ScopedListenable.builder((context, child) {
      return ScopedListenable(
        listenable: counterModel,
        child: child,
      );
    }),
  ],
  child: MyApp(),
);
```

To obtain Listenable directly, use extension methods. 

```dart
void initState() {
  context.read<CounterModel>().reset();
```
```dart
Widget build(BuildContext context) {
  final counterModel = context.watch<CounterModel>();
```

## Additional information

This is an updated version of [scoped_model](https://github.com/brianegan/scoped_model). Credits to the original authors and maintainers.
