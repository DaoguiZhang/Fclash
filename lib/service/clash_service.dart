import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kommon/kommon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:socket_io_client/socket_io_client.dart';

class ClashService extends GetxService {
  static const clashBaseUrl = "http://127.0.0.1:12345";
  // 运行时
  late Directory _clashDirectory;
  Process? _clashProcess;
  // 流量
  final uploadRate = 0.obs;
  final downRate = 0.obs;

  Future<bool> isRunning() async {
    Map<String, dynamic> resp = await Request.get(clashBaseUrl);
    if ('clash' == resp['hello']) {
      return true;
    }
    return false;
  }

  Future<ClashService> init() async {
    _clashDirectory = await getApplicationSupportDirectory();
    _clashDirectory =
        Directory.fromUri(Uri.parse(p.join(_clashDirectory.path, "clash")));

    final clashBin = p.join(_clashDirectory.path, 'clash');
    final clashConf = p.join(_clashDirectory.path, 'config.yaml');

    if (!await _clashDirectory.exists()) {
      await _clashDirectory.create(recursive: true);
    }
    // copy executable to directory
    final exe = await rootBundle.load('assets/tp/clash/clash');
    final yaml = await rootBundle.load('assets/tp/clash/config.yaml');
    // write to clash dir
    final exeF = File(clashBin);
    await exeF.writeAsBytes(exe.buffer.asInt8List());
    final yamlF = File(clashConf);
    await yamlF.writeAsBytes(yaml.buffer.asInt8List());
    // add permission
    final ret = Process.runSync('chmod', ['+x', clashBin], runInShell: true);
    if (ret.exitCode != 0) {
      Get.printError(
          info: 'fclash: no permission to add execute flag to $clashBin');
    }
    _clashProcess = await Process.start(
        clashBin, ['-d', _clashDirectory.path, '-f', clashConf],
        includeParentEnvironment: true, workingDirectory: _clashDirectory.path);
    Future.delayed(const Duration(seconds: 2), () async {
      final isOk = await isRunning();
      Get.printInfo(
          info: 'fclash daemon: ${isOk ? "running" : "not running!!"}');
      if (!isOk) {
        exit(1);
      } else {
        initDaemon();
      }
    });
    return this;
  }

  void initDaemon() async {
    final socket = io('$clashBaseUrl/traffic');
    socket.onDisconnect((data) {
      if (kDebugMode) {
        print('daemon disconnected.');
      }
    });
    socket.onConnect((data) {
      if (kDebugMode) {
        print('daemon disconnected.');
      }
    });
    socket.on('event', (data) {
      if (kDebugMode) {
        print(data);
      }
    });
  }

  @override
  void onClose() {
    Get.printInfo(info: 'fclash: closing daemon');
    _clashProcess?.kill();
    super.onClose();
  }

  void closeClashDaemon() {
    _clashProcess?.kill();
  }
}
