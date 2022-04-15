import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => BrnEnhanceNumberCard(
              backgroundColor: Colors.transparent,
              itemChildren: [
                BrnNumberInfoItemModel(
                    preDesc: "Download".tr,
                    number: Get.find<ClashService>()
                        .downRate
                        .value
                        .toStringAsFixed(1),
                    lastDesc: "KB/s"),
              ],
              rowCount: 4,
              itemTextAlign: TextAlign.center,
            )),
        Obx(() => BrnEnhanceNumberCard(
              backgroundColor: Colors.transparent,
              itemChildren: [
                BrnNumberInfoItemModel(
                    preDesc: "Upload".tr,
                    number: Get.find<ClashService>()
                        .uploadRate
                        .value
                        .toStringAsFixed(1),
                    lastDesc: "KB/s"),
              ],
              rowCount: 4,
              itemTextAlign: TextAlign.center,
            )),
      ],
    );
  }
}
