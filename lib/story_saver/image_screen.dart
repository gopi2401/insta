import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key, required this.imgUrl});
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imgUrl,
            child: InteractiveViewer(
              panEnabled: true, // Allows panning
              boundaryMargin: const EdgeInsets.all(
                  20), // Shrink the margin for easier panning
              minScale: 0.5, // Minimum scale to zoom out
              maxScale: 4.0, // Maximum scale to zoom in
              child: Image.network(
                imgUrl,
                fit: BoxFit
                    .contain, // Ensures the image maintains its aspect ratio
              ),
            ),
          ),
        ),
      ),
    );
  }
}
