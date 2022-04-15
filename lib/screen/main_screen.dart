import 'dart:io';

import 'package:fclash/screen/component/speed.dart';
import 'package:fclash/screen/page/about.dart';
import 'package:fclash/screen/page/clash_log.dart';
import 'package:fclash/screen/page/profile.dart';
import 'package:fclash/screen/page/proxy.dart';
import 'package:fclash/screen/page/setting.dart';
import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WindowListener, TrayListener {
  var index = 0.obs;

  @override
  void onWindowEvent(String eventName) {
    switch (eventName) {
      case "close":
        windowManager.hide();
        break;
    }
  }

  @override
  void onTrayIconMouseUp() {
    windowManager.show();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'exit':
        windowManager.close().then((value) {
          Get.find<ClashService>().closeClashDaemon();
          exit(0);
        });
        break;
      case 'show':
        windowManager.show();
    }
  }

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [buildOptions(), Expanded(child: buildFrame())],
    ));
  }

  Widget buildOptions() {
    return Row(
      children: [
        _buildOptions(0, 'Proxy'.tr),
        _buildOptions(1, 'Profile'.tr),
        _buildOptions(2, 'Setting'.tr),
        _buildOptions(3, 'Log'.tr),
        _buildOptions(4, 'About'.tr),
        const Expanded(
            child:
                Align(alignment: Alignment.centerRight, child: SpeedWidget()))
      ],
    );
  }

  Widget _buildOptions(int index, String title) {
    return InkWell(
      onTap: () {
        this.index.value = index;
      },
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
              color: index == this.index.value ? Colors.white : Colors.white12),
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget buildFrame() {
    return Obx(
      () => IndexedStack(
        index: index.value,
        children: const [
          Proxy(),
          Profile(),
          Setting(),
          ClashLog(),
          AboutPage()
        ],
      ),
    );
  }
}
