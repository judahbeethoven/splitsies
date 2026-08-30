// Smoke test: the app boots to the home screen with the DI graph wired to an
// in-memory (non-persistent) repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:splitsies/main.dart';
import 'package:splitsies/services/expense_repository.dart';
import 'package:splitsies/services/service_locator.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await resetLocator();
    await setupLocator(repository: MemoryRepo());
  });

  tearDown(resetLocator);

  testWidgets('app boots to the home screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Splitsies'), findsOneWidget);
    expect(find.text('add expense'), findsOneWidget);
    expect(find.textContaining('nothing logged yet'), findsOneWidget);
  });
}
