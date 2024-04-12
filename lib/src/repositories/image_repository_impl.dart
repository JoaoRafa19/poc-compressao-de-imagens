import 'dart:convert';

import 'package:poc_compressao/src/model/image_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import './image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  static const imageIdsbucket = 'images';
  @override
  Future<List<ImageModel>> getAllImages() async {
    final sp = await SharedPreferences.getInstance();
    final imageIdsList = sp.getStringList(imageIdsbucket);
    final imageList = <ImageModel>[];
    for (final id in imageIdsList ?? []) {
      final image = sp.getString(id);
      if (image == null) continue;
      imageList.add(ImageModel.fromJson(jsonDecode(image)));
    }
    return imageList;
  }

  @override
  Future<ImageModel?> getImage(String imageId) async {
    final sp = await SharedPreferences.getInstance();
    final imageString = sp.getString(imageId);
    if (imageString == null) {
      return null;
    }
    return ImageModel.fromJson(jsonDecode(imageString));
  }

  @override
  Future<String?> saveImage(ImageModel image) async {
    final sp = await SharedPreferences.getInstance();
    final imageIdsList = sp.getStringList(imageIdsbucket);
    if (image.imageId == null) {
      image = image.copyWith(imageId: () => const Uuid().v4());
    }
    imageIdsList?.add(image.imageId!);
    final result =
        await sp.setString(image.imageId!, jsonEncode(image.toJson()));
    if (result == false) throw Exception('Não foi possível salvar imagem');
    final resultList = await sp.setStringList(
        imageIdsbucket, imageIdsList ?? [image.imageId!]);
    if (resultList == false) throw Exception('Não foi possível salvar imagem');
    return image.imageId!;
  }

  @override
  Future<List<String>> getIds() async {
    final sp = await SharedPreferences.getInstance();
    final imageIdsList = sp.getStringList(imageIdsbucket);
    return imageIdsList ?? [];
  }
}
