import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';
import 'package:path/path.dart' as path;

class ViewPhotos extends StatefulWidget {
  final String imgPath;
  const ViewPhotos({
    Key? key,
    required this.imgPath,
  }) : super(key: key);

  @override
  _ViewPhotosState createState() => _ViewPhotosState();
}

class _ViewPhotosState extends State<ViewPhotos> {
  var filePath;
  final String imgShare = 'Image.file(File(widget.imgPath),)';

  final LinearGradient backgroundGradient = const LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x00333333),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final _fabMiniMenuItemList = [
    Icons.sd_card,
    Icons.share,
    Icons.reply,
    Icons.wallpaper,
    Icons.delete_outline,
  ];

  void _onLoading(bool t, String str) {
    if (t) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Center(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const CircularProgressIndicator()),
                ),
              ],
            );
          });
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleDialog(
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'Great, Saved in Gallary',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Text(str,
                              style: const TextStyle(
                                fontSize: 16.0,
                              )),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          const Text('FileManager > wa_status_saver',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.teal)),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          MaterialButton(
                            color: Colors.teal,
                            textColor: Colors.white,
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }
  }

  save() async {
    _onLoading(true, '');

    final myUri = Uri.parse(widget.imgPath);
    final originalImageFile = File.fromUri(myUri);

    // Read the file as bytes
    Uint8List bytes = await originalImageFile.readAsBytes();

    // Create the directory if it doesn't exist
    final dir = await Directory('/storage/emulated/0/Download/Insta/status')
        .create(recursive: true);

    // Write the bytes to a new file
    final newFile = File(path.join(dir.path, path.basename(widget.imgPath)));
    await newFile.writeAsBytes(bytes);

    // await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
    _onLoading(false,
        'If Image not available in gallary\n\nYou can find all images at');
  }

  @override
  Widget build(BuildContext context) {
    //The list of FabMiniMenuItems that we are going to use

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.indigo,
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                save();
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allows panning
          minScale: 0.5, // Minimum scale to zoom out
          maxScale: 4.0, // Maximum scale to zoom in
          child: Image.file(
            File(widget.imgPath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
