import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/modules/home/home_router.dart';

class HomeModule extends FlutterGetItModule {
  @override
  String get moduleRouteName => '/home';

  @override
  Map<String, WidgetBuilder> get pages => {
        '/': (context) => const HomeRouter(),
      };
}
