import 'package:poc_compressao/src/model/image_model.dart';

abstract interface class ImageRepository {
  Future<String?> saveImage(ImageModel image);
  Future<ImageModel?> getImage(String imageId);
  Future<List<ImageModel>> getAllImages();
  Future<List<String>> getIds();
}
