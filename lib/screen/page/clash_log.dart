import 'dart:async';
import 'dart:convert';

import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

class ClashLog extends StatefulWidget {
  const ClashLog({Key? key}) : super(key: key);

  @override
  State<ClashLog> createState() => _ClashLogState();
}

class _ClashLogState extends State<ClashLog> {
  final logs = RxList<String>();
  final connected = false.obs;
  static const logMaxLen = 1000;
  StreamSubscription<List<int>>? streamSubscription;

  @override
  void initState() {
    super.initState();
    tryConnect();
  }

  void tryConnect() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (streamSubscription == null) {
        if (Get.find<ClashService>().logStream == null) {
          // printInfo(info: 'clash log stream not opened');
        }
        streamSubscription =
            Get.find<ClashService>().logStream?.listen((event) {
          final logStr = utf8.decode(event);
          Get.printInfo(info: 'Log widget: $logStr');
          logs.insert(0, logStr);
          if (logs.length > logMaxLen) {
            logs.value = logs.sublist(logMaxLen);
          }
        });
        if (streamSubscription == null) {
          // printInfo(info: 'log service retry');
        } else {
          printInfo(info: 'log service connected'.tr);
          connected.value = true;
        }
      } else {
        connected.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    Get.printInfo(info: 'log dispose');
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => BrnNoticeBar(
            content: connected.value
                ? 'Log is running. Any logs will show below.'.tr
                : "No Logs currently / Connecting to clash log daemon...".tr,
            showLeftIcon: true,
            showRightIcon: true,
            noticeStyle: connected.value
                ? NoticeStyles.succeedWithArrow
                : NoticeStyles.runningWithArrow,
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white70),
            child: Obx(() => ListView.builder(
                  itemBuilder: (cxt, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: buildLogItem(logs[index]),
                    );
                  },
                  itemCount: logs.length,
                )),
          ),
        ),
      ],
    );
  }

  Widget buildLogItem(String log) {
    final json = jsonDecode(log) ?? {};
    return Stack(
      children: [
        Text(
          json['payload'] ?? "",
          style: TextStyle(fontFamily: 'nssc'),
        ),
        Align(
          alignment: Alignment.topRight,
          child: BrnStateTag(tagText: '${json['type']}'),
        )
      ],
    );
  }
}
