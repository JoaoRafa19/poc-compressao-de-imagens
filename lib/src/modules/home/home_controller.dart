import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:poc_compressao/src/model/image_model.dart';
import 'package:poc_compressao/src/repositories/image_repository.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeController {
  final ImageRepository imageRepository;

  HomeController(this.imageRepository);
  final images = signal<List<ImageModel>?>(null);
  final erros = signal<String?>(null);
  final messages = signal<String?>(null);
  final loading = signal<bool>(false);
  final sendProgress = signal<double?>(0.0);

  Future<void> init() async {
    try {
      loading.set(true);
      final savedImages = await imageRepository.getAllImages();
      log("Saved images, : ${savedImages.toSet()}");
      images.value = savedImages;
      loading.set(false);
    } catch (e) {
      loading.set(false);
      erros.value = "Erro ao buscar imagens";
    }
  }

  Future<Uint8List> compress(Uint8List list, int quality) async {
    final image = MemoryImage(list);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.resolve(const ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(info.image)));
    final width = (await completer.future).width;
    final height = (await completer.future).height;
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: height,
      minWidth: width,
      quality: quality,
    );
    return result;
  }

  Future<void> sendImages() async {
    loading.value = true;
    final sendImages = <ImageModel>[];
    messages.value = "Comprimindo imagens";
    for (final image
        in images.value?.where((element) => element.isSelected).toList() ??
            <ImageModel>[]) {
      final original = image.copyWith(
          imageName:
              "${image.imageName.split(".").first}original${image.imageName.split(".").last}");
      sendImages.add(original);
      final quality90 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 90),
          imageName:
              "${image.imageName.split(".").first}_90_${image.imageName.split(".").last}");

      sendImages.add(quality90);
      final quality80 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 80),
          imageName:
              "${image.imageName.split(".").first}_80_${image.imageName.split(".").last}");

      sendImages.add(quality80);
      final quality75 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 75),
          imageName:
              "${image.imageName.split(".").first}_75_${image.imageName.split(".").last}");

      sendImages.add(quality75);
      final quality65 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 65),
          imageName:
              "${image.imageName.split(".").first}_65_${image.imageName.split(".").last}");

      sendImages.add(quality65);
      final quality50 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 50),
          imageName:
              "${image.imageName.split(".").first}_50_${image.imageName.split(".").last}");

      sendImages.add(quality50);
      final quality40 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 40),
          imageName:
              "${image.imageName.split(".").first}_40_${image.imageName.split(".").last}");
      sendImages.add(quality40);
      final quality30 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 30),
          imageName:
              "${image.imageName.split(".").first}_30_${image.imageName.split(".").last}");
      sendImages.add(quality30);
      final quality20 = image.copyWith(
          base64Image:
              await compress(Uint8List.fromList(image.base64Image), 20),
          imageName:
              "${image.imageName.split(".").first}_20_${image.imageName.split(".").last}");

      sendImages.add(quality20);
    }
    messages.value = 'enviando...';
    final result = await imageRepository.sendImages(sendImages,
        progress: (current, total) {
      sendProgress.set((current * 100) / total);
    });
    if (result.fail > 0) {
      erros.set("${result.fail} com falha, ${result.succes} com sucesso");
    }
    messages.value = "recarregando view...";
    await init();
    loading.value = false;
  }
}
