import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:settings_ui/settings_ui.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final config = Get.find<ClashService>().configEntity;
    return Obx(
      () => config.value == null
          ? const BrnLoadingDialog()
          : SettingsList(platform: DevicePlatform.iOS, sections: [
              SettingsSection(
                title: Text("Proxy"),
                tiles: [
                  SettingsTile.navigation(
                    title: Text("proxy mode"),
                    value: Text(config.value!.mode.toString()),
                    onPressed: (cxt) {
                      handleProxyMode();
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text("Socks5 proxy port"),
                    value: Text(config.value!.socksPort.toString()),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for Socks5 proxy port',
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port', context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('socks-port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text("HTTP proxy port"),
                    value: Text(config.value!.port.toString()),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for HTTP proxy port',
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port', context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text("Redir proxy port"),
                    value: Text(config.value!.redirPort.toString()),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for redir proxy port',
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port', context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('redir-port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text("Mixed proxy port"),
                    value: Text(config.value!.mixedPort.toString()),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for mixed proxy port',
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port', context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('mixed-port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.switchTile(
                      title: Text("Allow LAN connection"),
                      initialValue: config.value?.allowLan,
                      onToggle: (e) {
                        Get.find<ClashService>()
                            .changeConfigField('allow-lan', e);
                      }),
                  SettingsTile.switchTile(
                      title: Text("Enable IPv6"),
                      initialValue: config.value?.ipv6,
                      onToggle: (e) {
                        Get.find<ClashService>().changeConfigField('ipv6', e);
                      }),
                ],
              ),
              SettingsSection(title: Text("System"), tiles: [
                SettingsTile.switchTile(
                    title: const Text("Set as system proxy"),
                    initialValue:
                        SpUtil.getData("system_proxy", defValue: false),
                    onToggle: (e) async {
                      if (e) {
                        Get.find<ClashService>().setSystemProxy();
                        await SpUtil.setData("system_proxy", true);
                      } else {
                        Get.find<ClashService>().clearSystemProxy();
                        await SpUtil.setData("system_proxy", false);
                      }
                      setState(() {
                        Tips.info("success");
                      });
                    }),
              ])
            ]),
    );
  }

  void handleProxyMode() {
    Get.bottomSheet(BrnCommonActionSheet(
      actions: [
        BrnCommonActionSheetItem('direct'),
        BrnCommonActionSheetItem('rule'),
        BrnCommonActionSheetItem('global'),
      ],
      onItemClickInterceptor: (index, s) {
        switch (index) {
          case 0:
            Get.find<ClashService>().changeConfigField('mode', 'Direct');
            break;
          case 1:
            Get.find<ClashService>().changeConfigField('mode', 'Rule');
            break;
          case 2:
            Get.find<ClashService>().changeConfigField('mode', 'Global');
            break;
        }
        return false;
      },
    ));
  }
}
