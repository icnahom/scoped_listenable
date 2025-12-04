import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoped_listenable/scoped_listenable.dart';

void main() {
  testWidgets('Provides a Listenable to decendant widgets', (tester) async {
    final counterModel = CounterModel();
    await tester.pumpWidget(
      ScopedListenable(
        listenable: counterModel,
        child: const Placeholder(),
      ),
    );
    expect(find.byType(ScopedListenable<CounterModel>), findsOneWidget);
  });

  testWidgets('Provides all the ScopedListenables to decendant widgets', (tester) async {
    final counterModel = CounterModel();
    final settingsModel = SettingsModel();
    await tester.pumpWidget(
      ScopedListenable.merge(
        listenables: [
          ScopedListenable.from(counterModel),
          ScopedListenable.from(settingsModel),
        ],
        child: const Placeholder(),
      ),
    );
    expect(find.byType(ScopedListenable<CounterModel>), findsOneWidget);
    expect(find.byType(ScopedListenable<SettingsModel>), findsOneWidget);
  });

  testWidgets('Provides all the ScopedListenables to decendant widgets (scoped)', (tester) async {
    final counterModel = CounterModel();
    final settingsModel = SettingsModel();
    await tester.pumpWidget(
      ScopedListenable.merge(
        listenables: [
          counterModel.scoped(),
          settingsModel.scoped(),
        ],
        child: const Placeholder(),
      ),
    );
    expect(find.byType(ScopedListenable<CounterModel>), findsOneWidget);
    expect(find.byType(ScopedListenable<SettingsModel>), findsOneWidget);
  });

  testWidgets('Rebuilds itself whenever Listenable of type T changes', (tester) async {
    final counterModel = CounterModel();
    await tester.pumpWidget(
      ScopedListenable(
        listenable: counterModel,
        child: MaterialApp(
          home: ScopedBuilder<CounterModel>(
            builder: (context, listenable, child) {
              return Text('${listenable.counter}');
            },
          ),
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    counterModel.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}

class CounterModel extends ChangeNotifier {
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}

class SettingsModel extends ChangeNotifier {}
