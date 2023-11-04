import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_photo/database_adapter.dart';
import 'package:flutter_photo/hive_database.dart';
import 'package:flutter_photo/utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:themed/themed.dart';
import 'package:widget_zoom/widget_zoom.dart';

class MultipleImageSelector extends StatefulWidget {
  const MultipleImageSelector({super.key});

  @override
  State<MultipleImageSelector> createState() => _MultipleImageSelectorState();
}

class _MultipleImageSelectorState extends State<MultipleImageSelector> {
  List<Uint8List> _selectedImages = [];
  final picker = ImagePicker();
  List<XFile> xfilePick = [];

  DatabaseAdapter adapter = HiveService();
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      List<Uint8List> imageList = await adapter.getImages();

      setState(() {
        _selectedImages = imageList;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Improver'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.purple)),
              child: const Text('Select Image from Gallery '),
              onPressed: () {
                getImagesFromGallery();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.purple)),
              child: const Text('Select Image from Camera '),
              onPressed: () {
                getImagesFromCamera();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                "All Photos: ",
                textScaleFactor: 2,
                style: TextStyle(color: Colors.purple),
              ),
            ),
            Expanded(
              child: SizedBox(
                child: _selectedImages.isEmpty
                    ? const Center(child: Text('No photos selected'))
                    : ListView.builder(
                        itemCount: _selectedImages.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Before:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    "After:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetZoom(
                                    heroAnimationTag: 'before',
                                    zoomWidget: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Image.memory(
                                        _selectedImages[index],
                                      ),
                                    ),
                                  ),
                                  Stack(
                                    children: [
                                      Screenshot(
                                        controller: screenshotController,
                                        child: WidgetZoom(
                                          heroAnimationTag: 'after',
                                          zoomWidget: SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: ChangeColors(
                                              hue: 0,
                                              brightness: 0.2,
                                              saturation: 0.2,
                                              child: Image.memory(
                                                _selectedImages[index],
                                                colorBlendMode: BlendMode.clear,
                                                filterQuality:
                                                    FilterQuality.high,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: IconButton(
                                            onPressed: () {
                                              saveToGallery(context);
                                            },
                                            icon: const Icon(
                                              Icons.download,
                                              color: Colors.white,
                                              size: 20,
                                            )),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImagesFromGallery() async {
    try {
      XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      Uint8List imageBytes = await pickedFile.readAsBytes();

      adapter.storeImage(imageBytes);
      _init();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getImagesFromCamera() async {
    try {
      XFile? pickedCameraFile = await picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedCameraFile == null) return;
      Uint8List imageBytes = await pickedCameraFile.readAsBytes();

      adapter.storeImage(imageBytes);
      _init();
    } catch (e) {
      print(e.toString());
    }
  }

  saveToGallery(BuildContext context) {
    screenshotController.capture().then((Uint8List? image) {
      saveImage(image!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved to gallery.'),
        ),
      );
    }).catchError((err) => print(err));
  }

  saveImage(Uint8List bytes) async {
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = "screenshot_$time";
    await requestPermission(Permission.storage);
    await ImageGallerySaver.saveImage(bytes, name: name);
  }
}
