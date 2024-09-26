import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta/utils/function.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'video_controller.dart';

class PlayStatus extends StatefulWidget {
  final String videoFile;
  const PlayStatus({
    Key? key,
    required this.videoFile,
  }) : super(key: key);
  @override
  PlayStatusState createState() => PlayStatusState();
}

class PlayStatusState extends State<PlayStatus> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLoading(bool t, String? str) {
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
    } else if (str != null) {
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
                          const Text('FileManager > Download > insta > status',
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
    } else {
      Navigator.pop(context);
    }
  }

  void save() async {
    try {
      _onLoading(true, '');

      final originalVideoFile = File(widget.videoFile);
      if (!Directory('/storage/emulated/0/Download/Insta/Status')
          .existsSync()) {
        Directory('/storage/emulated/0/Download/Insta/Status')
            .createSync(recursive: true);
      }
      final newFileName =
          '/storage/emulated/0/Download/Insta/Status/${path.basename(originalVideoFile.path)}';
      await originalVideoFile.copy(newFileName);

      _onLoading(
        false,
        'If Video not available in gallary\n\nYou can find all videos at',
      );
    } catch (e, stackTrace) {
      _onLoading(false, null);
      catchInfo(e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () => save(),
          ),
        ],
      ),
      body: StatusVideo(
        videoPlayerController:
            VideoPlayerController.file(File(widget.videoFile)),
        looping: true,
        videoSrc: widget.videoFile,
      ),
    );
  }
}
