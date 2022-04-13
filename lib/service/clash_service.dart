import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fclash/bean/clash_config_entity.dart';
import 'package:flutter/services.dart';
import 'package:kommon/kommon.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ClashService extends GetxService {
  static const clashBaseUrl = "http://127.0.0.1:22345";

  // 运行时
  late Directory _clashDirectory;
  Process? _clashProcess;

  // 流量
  final uploadRate = 0.0.obs;
  final downRate = 0.0.obs;
  final yamlConfigs = RxList<FileSystemEntity>.empty(growable: true);
  final currentYaml = 'config.yaml'.obs;

  // config
  Rx<ClashConfigEntity?> configEntity = Rx(null);

  // log
  Stream<List<int>>? logStream;
  RxMap<String, dynamic> proxies = RxMap();

  Future<bool> isRunning() async {
    try {
      Map<String, dynamic> resp = await Request.get(clashBaseUrl,
          options: Options(sendTimeout: 1000, receiveTimeout: 1000));
      if ('clash' == resp['hello']) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<ClashService> init() async {
    // init config yaml
    final _ = SpUtil.getData('yaml', defValue: currentYaml.value);
    currentYaml.value = _;
    // init clash
    Request.setBaseUrl(clashBaseUrl);
    _clashDirectory = await getApplicationSupportDirectory();
    _clashDirectory =
        Directory.fromUri(Uri.parse(p.join(_clashDirectory.path, "clash")));

    final clashBin = p.join(_clashDirectory.path, 'clash');
    final clashConf = p.join(_clashDirectory.path, currentYaml.value);
    if (await isRunning()) {
      printError(
          info:
              "running Fclash in client mode. clash is not handled by Fclash!");
    } else {
      print("running Fclash in standalone mode.");
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
          includeParentEnvironment: true,
          workingDirectory: _clashDirectory.path);
      _clashProcess?.stdout.listen((event) {
        Get.printInfo(info: String.fromCharCodes(event));
      });
      _clashProcess?.stderr.listen((event) {
        Get.printInfo(info: String.fromCharCodes(event));
      });
    }
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      final isOk = await isRunning();
      Get.printError(
          info: 'fclash daemon: ${isOk ? "running" : "not running!!"}');
      if (isOk) {
        timer.cancel();
        initDaemon();
      }
    });
    return this;
  }

  void getConfigs() {
    yamlConfigs.clear();
    _clashDirectory.list().listen((entity) {
      if (entity.path.toLowerCase().endsWith('.yaml')) {
        yamlConfigs.add(entity);
        Get.printInfo(info: 'detected: ${entity.path}');
      }
    });
  }

  Future<void> getCurrentClashConfig() async {
    configEntity.value =
        ClashConfigEntity.fromJson(await Request.get('/configs'));
  }

  Future<void> reload() async {
    // get configs
    getConfigs();
    getCurrentClashConfig();
    // proxies
    getProxies();
  }

  void initDaemon() async {
    printInfo(info: 'init clash service');
    // get traffic
    getTraffic().then((value) {
      if (value != null) {
        Get.printInfo(info: 'connected to traffic');
        value.listen((event) {
          final msg = String.fromCharCodes(event);
          try {
            final traffic_json = jsonDecode(msg);
            Get.printInfo(info: '[traffic]: $msg');
            uploadRate.value = traffic_json['up'].toDouble();
            downRate.value = traffic_json['down'].toDouble();
          } catch (e) {
            Get.printError(info: '$e');
          }
        });
      }
    });
    _getLog().then((stream) {
      logStream = stream?.asBroadcastStream();
      if (logStream == null) {
        printError(info: 'log stream opened failed!');
      } else {
        print("log stream opened success");
      }
      logStream?.listen((event) {
        Get.printInfo(info: '[LOG]: ${String.fromCharCodes(event)}');
      });
    });
    // daemon
    Timer.periodic(const Duration(seconds: 1), (timer) {
      timer.cancel();
      isRunning().then((value) {
        if (!value) {
          // start clash backend again
          init();
        }
      });
    });
    reload();
  }

  @override
  void onClose() {
    closeClashDaemon();
    super.onClose();
  }

  void closeClashDaemon() {
    Get.printInfo(info: 'fclash: closing daemon');
    _clashProcess?.kill();
  }

  Future<void> getProxies() async {
    final proxies = await Request.get('/proxies');
    this.proxies.value = proxies;
  }

  Future<Stream<Uint8List>?> getTraffic() async {
    Response<ResponseBody> resp = await Request.dioClient
        .get('/traffic', options: Options(responseType: ResponseType.stream));
    return resp.data?.stream;
  }

  /// TODO blocking
  Future<Stream<Uint8List>?> _getLog({String type = "info"}) async {
    Response<ResponseBody> resp = await Request.dioClient.get('/logs',
        options: Options(responseType: ResponseType.stream),
        queryParameters: {"level": type});
    return resp.data?.stream;
  }

  Future<bool?> downloadSubscriptionFile() async {
    // TODO
    return false;
  }

  Future<bool> _changeConfig(FileSystemEntity config) async {
    final resp = await Request.dioClient.put('/configs',
        queryParameters: {"force": false}, data: {"path": config.path});
    Get.printInfo(info: 'config changed ret: ${resp.statusCode}');
    currentYaml.value = basename(config.path);
    return resp.statusCode == 204;
  }

  Future<bool> changeYaml(FileSystemEntity config) async {
    try {
      if (await config.exists()) {
        return await _changeConfig(config);
      } else {
        return false;
      }
    } finally {
      reload();
    }
  }

  void deleteYaml(FileSystemEntity config) {}

  Future<bool> changeProxy(selectName, String proxyName) async {
    final resp = await Request.dioClient
        .put('/proxies/$selectName', data: {"name": proxyName});
    if (resp.statusCode == 204) {
      reload();
    }
    return resp.statusCode == 204;
  }

  Future<bool> changeConfigField(String field, dynamic value) async {
    try {
      final resp =
          await Request.dioClient.patch('/configs', data: {field: value});
      return resp.statusCode == 204;
    } finally {
      getCurrentClashConfig();
    }
  }
}
