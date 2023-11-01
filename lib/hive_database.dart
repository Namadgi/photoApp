import 'dart:typed_data';

import 'package:flutter_photo/database_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService extends DatabaseAdapter {
  late Box box;

  HiveService() {
    _init();
  }

  void _init() async {
    box = await Hive.openBox('imageBox');
  }

  @override
  Future<List<Uint8List>> getImages() async {
    List<dynamic>? result = box.get('images');
    return result?.cast<Uint8List>() ?? [];
  }

  @override
  Future storeImage(Uint8List imageBytes) async {
    List<Uint8List>? images = box.get('images');
    if (images == null) {
      images = [imageBytes];
    } else {
      images.add(imageBytes);
    }
    await box.put("images", images);
  }
}

// class HiveService extends DatabaseAdapter {
//   @override
//   Future<List<Uint8List>> getImages() async {
//     var box = await Hive.openBox('imageBox');

//     List<dynamic> result = box.get('images') ?? [];

//     return result.cast<Uint8List>();
//   }

//   @override
//   Future storeImage(Uint8List imageBytes) async {
//     List<Uint8List> images = [];

//     var box = await Hive.openBox('imageBox');

//     List<dynamic>? allImages = box.get('images');

//     if (allImages != null) {
//       images.addAll(allImages.cast<Uint8List>());
//     }

//     images.add(imageBytes);

//     var value = await box.put("images", images);

//     return value;
//   }
// }
