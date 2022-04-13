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
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => BrnNoticeBar(
                  content:
                      'Current using: ${Get.find<ClashService>().currentYaml.value}')),
              Expanded(child: Obx(() => buildTiles()))
            ],
          ),
          Opacity(
              opacity: 0.4,
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/images/network.png",
                    width: 300,
                  )))
        ],
      ),
    );
  }

  Widget buildTiles() {
    final c = Get.find<ClashService>().proxies;
    if (c.value == null) {
      return BrnAbnormalStateWidget(
        title: 'No Proxies',
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
    return BrnExpandableGroup(
      title: selector['name'] ?? "",
      subtitle: selector['now'],
      children: [
        buildSelectItem(selector),
        // for debug
        // kDebugMode ? BrnExpandableText(text: selector.toString(),maxLines: 1,textStyle: TextStyle(fontSize: 20,
        // color: Colors.black),) : Offstage(),
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
        return BrnRadioButton(
            radioIndex: index++,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                itemName,
                style: TextStyle(fontSize: 20),
              ),
            ),
            onValueChangedAtIndex: (newIndex, value) {
              Get.find<ClashService>()
                  .changeProxy(selectName, allItems[newIndex])
                  .then((res) {
                if (res) {
                  BrnToast.show(
                      'switch to ${allItems[newIndex]} success.', context);
                } else {
                  BrnToast.show(
                      'switch to ${allItems[newIndex]} failed.', context);
                }
              });
            },
            isSelected: itemName == now);
      }).toList(growable: false),
    );
  }
}
