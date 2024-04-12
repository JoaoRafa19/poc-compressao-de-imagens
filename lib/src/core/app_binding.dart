import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/core/enviroment.dart';
import 'package:poc_compressao/src/core/rest_client.dart';
import 'package:poc_compressao/src/repositories/image_repository.dart';
import 'package:poc_compressao/src/repositories/image_repository_impl.dart';

class MainBinding extends ApplicationBindings {
  @override
  List<Bind<Object>> bindings() => [
        Bind.lazySingleton((i) => RestClient(Env.backendBaseUrl)),
        Bind.lazySingleton<ImageRepository>((i) => ImageRepositoryImpl()),
      ];
}
