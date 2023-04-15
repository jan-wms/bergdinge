import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageCrop extends StatefulWidget {
  final File imgFile;

  const ImageCrop({required this.imgFile, Key? key}) : super(key: key);

  @override
  State<ImageCrop> createState() => _ImageCropState();
}

class _ImageCropState extends State<ImageCrop> {
  final _controller = CropController();
  final TextStyle _textStyle = const TextStyle(color: Colors.white);
  late final File imgFile;

  @override
  void initState() {
    super.initState();
    imgFile = widget.imgFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bewegen und skalieren',
                style: _textStyle,
              ),
              Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Crop(
                      progressIndicator:
                          const CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white),
                      fixArea: true,
                      image: imgFile.readAsBytesSync(),
                      controller: _controller,
                      withCircleUi: true,
                      baseColor: Colors.black,
                      initialAreaBuilder: (rect) {
                        return Rect.fromCircle(
                            center: Offset(constraints.maxWidth / 2,
                                constraints.maxHeight / 2),
                            radius: (constraints.maxWidth / 2) - 20);
                      },
                      cornerDotBuilder: ((d, e) {
                        return Container();
                      }),
                      interactive: true,
                      onCropped: (value) async {
                        img.Image? image = img.decodeImage(value);
                        img.Image resized =
                            img.copyResize(image!, width: 200, height: 200);
                        Uint8List resizedImg =
                            Uint8List.fromList(img.encodePng(resized));
                        context.pop(resizedImg);
                      }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Abbrechen')),
                  TextButton(
                      onPressed: () => _controller.crop(),
                      child: const Text('Auswählen')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
