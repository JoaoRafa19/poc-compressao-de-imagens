import 'package:poc_compressao/src/model/image_model.dart';
import 'package:poc_compressao/src/repositories/image_repository.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeController {
  final ImageRepository imageRepository;

  HomeController(this.imageRepository) {
    init();
  }

  final images = signal<List<ImageModel>?>(null);

  Future<void> init() async {
    final _images = await imageRepository.getAllImages();
    images.value = _images;
  }
}
