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

  static const minDimension = 1920 * 1080;

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

  Future<void> removeImage(ImageModel? image) async {
    if (image == null) return;
    loading.set(true);
    await imageRepository.removeImage(image);
    init();
    loading.set(false);
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
              "${image.imageName.split(".").first}_ORIGINAL_${image.imageName.split(".").last}");

      sendImages.add(original);

      var uint8list = Uint8List.fromList(image.base64Image);
      final memoryImage = MemoryImage(uint8list);
      Completer<ui.Image> completer = Completer<ui.Image>();
      memoryImage.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
              (ImageInfo info, bool _) => completer.complete(info.image)));
      final int width = (await completer.future).width;
      final int height = (await completer.future).height;
      final int quality = (width * height) >= minDimension ? 50 : 80;
      var compressedImage = await FlutterImageCompress.compressWithList(
        uint8list,
        minHeight: height,
        minWidth: width,
        quality: quality,
      );

      final sendImage = image.copyWith(
          base64Image: compressedImage,
          imageName:
              "${image.imageName.split(".").first}_${quality}_${image.imageName.split(".").last}");

      sendImages.add(sendImage);
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
