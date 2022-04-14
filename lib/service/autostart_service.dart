import 'dart:io';

import 'package:fclash/tools/autostart_utils.dart';
import 'package:kommon/kommon.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AutostartService extends GetxService {
  var isEnabled = false.obs;

  Future<AutostartService> init() async {
    // setup
    final packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
        appName: packageInfo.appName, appPath: Platform.resolvedExecutable);
    isEnabled.value = await launchAtStartup.isEnabled();
    return this;
  }

  Future<bool> enableAutostart() async {
    isEnabled.value = await AutostartUtils.enable();
    return isEnabled.value;
  }

  Future<bool> disableAutostart() async {
    isEnabled.value = !(await AutostartUtils.disable());
    return isEnabled.value;
  }
}
