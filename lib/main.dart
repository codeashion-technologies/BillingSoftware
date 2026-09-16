import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'core/database/database_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(920, 500),
      minimumSize: Size(920, 500),
      maximumSize: Size(920, 500),
      center: true,
      backgroundColor: Color(0x00000000),
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    ),
    () async {
      await windowManager.setAsFrameless();
      await windowManager.center();
      await windowManager.show();
      await windowManager.focus();
    },
  );
  Bloc.observer = AppBlocObserver();
  await DatabaseInitializer.initialize();
  runApp(const AccountingApp());
}
