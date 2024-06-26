import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/modules/home/home_controller.dart';
import 'package:poc_compressao/src/modules/home/home_page.dart';

class HomeRouter extends FlutterGetItModulePageRouter {
  const HomeRouter({super.key});

  @override
  List<Bind<Object>> get bindings =>
      [Bind.lazySingleton<HomeController>((i) => HomeController(i()))];

  @override
  WidgetBuilder get view => (_) => const HomePage();
}
