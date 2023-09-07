import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  testWidgets('Provides a Listenable model to decendant widgets',
      (tester) async {
    final counterModel = CounterModel();
    await tester.pumpWidget(
      ScopedModel(
        model: counterModel,
        child: const Placeholder(),
      ),
    );
    expect(find.byType(ScopedModel<CounterModel>), findsOneWidget);
  });

  testWidgets('Provides all the ScopedModels to decendant widgets',
      (tester) async {
    final counterModel = CounterModel();
    final settingsModel = SettingsModel();
    await tester.pumpWidget(
      ScopedContainer(
        container: [
          ScopedModel.from(counterModel),
          ScopedModel.from(settingsModel),
        ],
        child: const Placeholder(),
      ),
    );
    expect(find.byType(ScopedModel<CounterModel>), findsOneWidget);
    expect(find.byType(ScopedModel<SettingsModel>), findsOneWidget);
  });

  testWidgets('Builds itself whenever Listenable of type T changes',
      (tester) async {
    final counterModel = CounterModel();
    await tester.pumpWidget(
      ScopedModel(
        model: counterModel,
        child: MaterialApp(
          home: ScopedBuilder<CounterModel>(
            builder: (context, model, child) {
              return Text('${model.counter}');
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
