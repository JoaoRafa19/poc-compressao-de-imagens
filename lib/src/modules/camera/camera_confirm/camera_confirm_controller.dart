import 'dart:typed_data';
import 'package:poc_compressao/src/model/image_model.dart';
import 'package:poc_compressao/src/repositories/image_repository.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CameraConfirmController {
  final ImageRepository imageRepository;

  CameraConfirmController(this.imageRepository);

  final pathRemoteStorage = signal<String?>(null);
  final loading = signal<bool>(false);
  final errorMessage = signal<String?>(null);

  Future<void> uploadImage(Uint8List imageByte, String filename) async {
    try {
      loading.set(true);

      final model = ImageModel(base64Image: imageByte, imageName: filename);
      final result = await imageRepository.saveImage(model);
      pathRemoteStorage.set(result);
    } on Exception catch (e) {
      errorMessage.set("Erro ao salvar a foto");
    }
    loading.set(false);
  }
}
