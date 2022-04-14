import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

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
              "Fclash - a clash proxy fronted by Flutter",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Text(
            "version: v1.0",
            style: TextStyle(fontSize: 20),
          ),
          Divider(
            thickness: 1.0,
          ),
          Text("Author: Kingtous"),
          TextButton(
              onPressed: () {
                LaunchUtils.openUrl("https://github.com/Kingtous");
              },
              child: Text("View me at Github"))
        ],
      ),
    );
  }
}
