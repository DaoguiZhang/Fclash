import 'package:fclash/screen/main_screen.dart';
import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppService();
  runApp(const MyApp());
  initAppTray();
}

void initAppTray({List<MenuItem>? details}) async {
  await trayManager.setIcon('assets/images/app_tray.jpeg');
  List<MenuItem> items = [
    MenuItem(
      key: 'show',
      title: 'Show Fclash',
    ),
    MenuItem.separator,
    MenuItem(
      key: 'exit',
      title: 'Exit Fclash',
    ),
  ];
  if (details != null) {
    items.insertAll(0, details);
  }
  await trayManager.setContextMenu(items);
}

Future<void> initAppService() async {
  await windowManager.setPreventClose(true);
  await SpUtil.getInstance();
  await Get.putAsync(() => ClashService().init());
  await Get.putAsync(() => DialogService().init());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fclash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'nssc'),
      home: const MainScreen(),
    );
  }
}
