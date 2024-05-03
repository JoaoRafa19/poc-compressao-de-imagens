import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/modules/camera/camera_confirm/camera_confirm_controller.dart';
import 'package:poc_compressao/src/modules/camera/camera_confirm/camera_confirm_page.dart';

class CameraConfirmRouter extends FlutterGetItModulePageRouter {
  const CameraConfirmRouter({super.key});

  @override
  List<Bind<Object>> get bindings => [
        Bind.lazySingleton<CameraConfirmController>(
            (i) => CameraConfirmController(i()))
      ];

  @override
  WidgetBuilder get view => (_) => const CameraConfirmPage();
}
