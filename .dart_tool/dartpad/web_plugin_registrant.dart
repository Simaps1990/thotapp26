// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:audioplayers_web/audioplayers_web.dart';
import 'package:device_info_plus/src/device_info_plus_web.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter_secure_storage_web/flutter_secure_storage_web.dart';
import 'package:geolocator_web/geolocator_web.dart';
import 'package:package_info_plus/src/package_info_plus_web.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:printing/printing_web.dart';
import 'package:purchases_flutter/web/purchases_flutter_web.dart';
import 'package:share_plus/src/share_plus_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  AudioplayersPlugin.registerWith(registrar);
  DeviceInfoPlusWebPlugin.registerWith(registrar);
  FilePickerWeb.registerWith(registrar);
  FlutterSecureStorageWeb.registerWith(registrar);
  GeolocatorPlugin.registerWith(registrar);
  PackageInfoPlusWebPlugin.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  PrintingPlugin.registerWith(registrar);
  PurchasesFlutterPlugin.registerWith(registrar);
  SharePlusWebPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
