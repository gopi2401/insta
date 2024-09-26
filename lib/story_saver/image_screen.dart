import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen(
      {super.key, required this.imgUrl, required this.profilePicDownload});
  final String imgUrl;
  final Function profilePicDownload;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                profilePicDownload();
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: InteractiveViewer(
            panEnabled: true, // Allows panning
            // boundaryMargin: const EdgeInsets.all(
            //     20), // Shrink the margin for easier panning
            minScale: 0.5, // Minimum scale to zoom out
            maxScale: 4.0, // Maximum scale to zoom in
            child: Image.network(
              imgUrl,
              fit: BoxFit
                  .fitWidth, // Ensures the image maintains its aspect ratio
            ),
          ),
        ),
      ),
    );
  }
}
