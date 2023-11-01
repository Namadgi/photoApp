import 'package:flutter/foundation.dart';

abstract class DatabaseAdapter {
  Future<void> storeImage(Uint8List imageBytes);

  Future<List<Uint8List>> getImages();
}
