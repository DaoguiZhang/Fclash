import 'package:fclash/service/clash_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

class Proxy extends StatefulWidget {
  const Proxy({Key? key}) : super(key: key);

  @override
  State<Proxy> createState() => _ProxyState();
}

class _ProxyState extends State<Proxy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Get.find<ClashService>();
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Opacity(
              opacity: 0.4,
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/images/network.png",
                    width: 300,
                  ))),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => BrnNoticeBar(
                  content: 'Current using'
                      .trParams({"name": cs.currentYaml.value}))),
              Obx(() => BrnNoticeBar(
                    noticeStyle: cs.isSystemProxyObs.value
                        ? NoticeStyles.succeedWithArrow
                        : NoticeStyles.warningWithArrow,
                    content: cs.isSystemProxyObs.value
                        ? "Fclash is running as system proxy now. Enjoy.".tr
                        : 'Fclash is not set as system proxy. Software may not automatically use Fclash proxy.'
                            .tr,
                    rightWidget: cs.isSystemProxyObs.value
                        ? Offstage()
                        : TextButton(
                            onPressed: () {
                              cs.setSystemProxy();
                            },
                            child: Text("set Fclash as system proxy".tr)),
                  )),
              Expanded(child: Obx(() => buildTiles()))
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTiles() {
    final c = Get.find<ClashService>().proxies;
    if (c.value == null) {
      return BrnAbnormalStateWidget(
        title: 'No Proxies'.tr,
        content: 'Select a profile to show proxies.',
      );
    }
    Map<String, dynamic> maps = c.value['proxies'] ?? {};
    printInfo(info: 'proxies: ${maps.toString()}');

    final selectors = maps.keys.where((proxy) {
      return maps[proxy]['type'] == 'Selector';
    }).toList(growable: false);

    return ListView.builder(
      itemBuilder: (context, index) {
        final selectorName = selectors[index];
        return buildSelector(maps[selectorName]);
      },
      itemCount: selectors.length,
    );
  }

  Widget buildSelector(Map<String, dynamic> selector) {
    final proxyName = selector['name'];
    return Stack(
      children: [
        BrnExpandableGroup(
          title: proxyName ?? "",
          subtitle: selector['now'],
          themeData: BrnFormItemConfig(
            titleTextStyle: BrnTextStyle(fontSize: 20),
            subTitleTextStyle: BrnTextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.transparent,
          children: [
            buildSelectItem(selector),
            // for debug
            // kDebugMode ? BrnExpandableText(text: selector.toString(),maxLines: 1,textStyle: TextStyle(fontSize: 20,
            // color: Colors.black),) : Offstage(),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () async {
                BrnLoadingDialog.show(context, barrierDismissible: false);
                try {
                  await Get.find<ClashService>().delay(proxyName).then((value) {
                    if (value is int) {
                      BrnToast.show(
                          "$proxyName-${selector['now']}: $value ms", context);
                    } else {
                      BrnToast.show("Error: $proxyName: $value", context);
                      // Tips.info("$proxyName: $value");
                    }
                  });
                } finally {
                  BrnLoadingDialog.dismiss(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Test Delay".tr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )),
        )
      ],
    );
  }

  Widget buildSelectItem(Map<String, dynamic> selector) {
    final selectName = selector['name'];
    final now = selector['now'];
    List<dynamic> allItems = selector['all'];
    var index = 0;
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: allItems.map((itemName) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: BrnRadioButton(
              radioIndex: index++,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      itemName,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              onValueChangedAtIndex: (newIndex, value) {
                Get.find<ClashService>()
                    .changeProxy(selectName, allItems[newIndex])
                    .then((res) {
                  if (res) {
                    BrnToast.show(
                        'switch to name success.'
                            .trParams({"name": "${allItems[newIndex]}"}),
                        context);
                  } else {
                    BrnToast.show(
                        'switch to name failed.'
                            .trParams({"name": "${allItems[newIndex]}"}),
                        context);
                  }
                });
              },
              isSelected: itemName == now),
        );
      }).toList(growable: false),
    );
  }
}
