import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:poc_compressao/src/core/rest_client.dart';
import 'package:poc_compressao/src/model/image_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import './image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final RestClient restClient;

  ImageRepositoryImpl(this.restClient);

  static const imageIdsbucket = 'images';
  @override
  Future<List<ImageModel>> getAllImages() async {
    final sp = await SharedPreferences.getInstance();
    final imageIdsList = sp.getStringList(imageIdsbucket);
    final imageList = <ImageModel>[];
    for (final id in imageIdsList ?? []) {
      final image = sp.getString(id);
      if (image == null) {
        sp.remove(id);
        continue;
      }
      try {
        imageList.add(ImageModel.fromJson(jsonDecode(image)));
      } catch (e) {
        sp.remove(id);
        continue;
      }
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
    final modelString = jsonEncode(image.toJson());
    final result = await sp.setString(image.imageId!, modelString);
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

  @override
  Future<({int succes, int fail})> sendImages(List<ImageModel> images,
      {Function(int, int)? progress}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      int succeses = 0;
      int fails = 0;

      for (final image in images) {
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            image.base64Image,
            filename: image.imageName,
          ),
          'directory': 'comprimir',
          'container': 'images'
        });
        final token = String.fromEnvironment('TOKEN');
        final options = Options(
            persistentConnection: true,
            headers: {
              "Content-Type": "multipart/form-data;charset",
              "Accept-Language": "pt-BR",
              "Accept": "application/json",
              "Authorization": token
            },
            extra: {"DIO_AUTH_KEY": true},
            sendTimeout: const Duration(minutes: 1));
        try {
          final dio = Dio()..interceptors.add(AuthInterceptor());
          final response = await dio.post(
              "https://apimw.traderesult.app/v1/files",
              data: formData,
              options: options);
          response.statusCode == 200 ? succeses++ : fails++;
          if (response.statusCode == 200) {
            sp.remove(image.imageId ?? "");
          }
          succeses++;
        } catch (e) {
          fails++;
        }
        progress?.call(images.indexOf(image), images.length);
      }
      return (succes: succeses, fail: fails);
    } catch (e) {
      return (succes: 0, fail: images.length);
    }
  }
}
