import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ImageModel {
  @JsonKey(name: 'base64image')
  final String base64Image;
  @JsonKey(name: 'image_name')
  final String imageName;

  final String? imageId;

  ImageModel({
    required this.base64Image,
    required this.imageName,
    this.imageId,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
      base64Image: json["base64Image"],
      imageId: json['id'],
      imageName: json['image_name']);

  Map<String, dynamic> toJson() => {
        "base64Image": base64Image,
        "image_name": imageName,
        "id": imageId,
      };

  ImageModel copyWith({
    String? imagePath,
    String? base64Image,
    String? imageName,
    ValueGetter<String?>? imageId,
  }) {
    return ImageModel(
      base64Image: base64Image ?? this.base64Image,
      imageName: imageName ?? this.imageName,
      imageId: imageId != null ? imageId() : this.imageId,
    );
  }
}
