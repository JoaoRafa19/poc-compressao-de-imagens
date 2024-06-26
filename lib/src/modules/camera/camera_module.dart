import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/modules/camera/camera_confirm/camera_confirm_router.dart';
import 'package:poc_compressao/src/modules/camera/camera_controller.dart';
import 'package:poc_compressao/src/modules/camera/camera_scan/camera_page.dart';

class CameraModule extends FlutterGetItModule {
  @override
  String get moduleRouteName => '/camera';

  @override
  List<Bind<Object>> get bindings =>
      [Bind.lazySingleton<CameraPageController>((i) => CameraPageController())];

  @override
  Map<String, WidgetBuilder> get pages => {
        '/': (context) => const CameraPage(),
        '/confirm': (_) => const CameraConfirmRouter()
      };
}
