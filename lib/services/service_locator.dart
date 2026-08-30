import 'package:get_it/get_it.dart';
import 'package:splitsies/services/expense_repository.dart';
import 'package:splitsies/services/expense_service.dart';
import 'package:splitsies/services/user_settings_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator({ExpenseRepository? repository}) async {
  if (getIt.isRegistered<ExpenseService>()) return;

  getIt.registerSingleton<ExpenseRepository>(repository ?? LocalRepo());

  final service = ExpenseService(getIt<ExpenseRepository>());
  await service.init();
  getIt.registerSingleton<ExpenseService>(service);

  final settings = UserSettingsService();
  await settings.init();
  getIt.registerSingleton<UserSettingsService>(settings);
}

Future<void> resetLocator() async {
  if (getIt.isRegistered<ExpenseService>()) {
    getIt<ExpenseService>().dispose();
  }
  if (getIt.isRegistered<UserSettingsService>()) {
    getIt<UserSettingsService>().dispose();
  }
  await getIt.reset();
}
