import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: CircleAvatar(
              foregroundImage: AssetImage("assets/images/app_tray.jpeg"),
              radius: 100,
            ),
          ),
          TextButton(
            onPressed: () {
              LaunchUtils.openUrl("https://github.com/Kingtous/Fclash");
            },
            child: Text(
              "Fclash - a clash proxy fronted by Flutter".tr,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              if (snap.hasData) {
                PackageInfo info = snap.data as PackageInfo;
                return Text(
                  "version:".trParams({"version": info.version}),
                  style: const TextStyle(fontSize: 20),
                );
              } else {
                return const BrnLoadingDialog();
              }
            },
          ),
          TextButton(
              onPressed: () {
                LaunchUtils.openUrl(
                    "https://github.com/Kingtous/Fclash/actions");
              },
              child: Text("check for update".tr)),
          const Divider(
            thickness: 1.0,
          ),
          Text("Author:".trParams({"name": "Kingtous"})),
          TextButton(
              onPressed: () {
                LaunchUtils.openUrl("https://github.com/Kingtous");
              },
              child: Text("View me at Github".tr))
        ],
      ),
    );
  }
}
