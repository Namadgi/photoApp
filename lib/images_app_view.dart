import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_photo/database_adapter.dart';
import 'package:flutter_photo/hive_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:themed/themed.dart';

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

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    List<Uint8List> imageList = await adapter.getImages();

    setState(() {
      _selectedImages = imageList;
    });
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
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Image.memory(
                                      _selectedImages[index],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: ChangeColors(
                                      hue: 0,
                                      brightness: 0.2,
                                      saturation: 0.2,
                                      child: Image.memory(
                                        _selectedImages[index],
                                        colorBlendMode: BlendMode.clear,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
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
    XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    Uint8List imageBytes = await pickedFile.readAsBytes();

    adapter.storeImage(imageBytes);
    _init();
  }

  Future<void> getImagesFromCamera() async {
    XFile? pickedCameraFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedCameraFile == null) return;
    Uint8List imageBytes = await pickedCameraFile.readAsBytes();

    adapter.storeImage(imageBytes);
    _init();
  }
}
