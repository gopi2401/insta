import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../Functions/fileDownload.dart';

class Video extends StatefulWidget {
  const Video({super.key, required this.data});
  final dynamic data;

  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<Video> {
  late VideoPlayerController _controller;
  late FileDownload downloadController;
  late double _progressValue;
  bool isMusicOn = true;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse('widget.url'))
      ..initialize().then((_) {
        _controller.addListener(checkVideo);
        _controller.play();
        setState(() {});
      });
    _progressValue = 0.0;
    downloadController = Get.put(FileDownload());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 35),
            ),
            const Padding(padding: EdgeInsets.only(top: 10, right: 5)),
            AppBar(
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: _progressValue),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            minHeight: 5,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            value: value,
                          );
                        })),
              ),
              backgroundColor: Colors.transparent,
              // forceMaterialTransparency: true,
              shadowColor: Colors.transparent,
              title: Text('',
                  style: const TextStyle(color: Colors.white, fontSize: 5)),
              toolbarHeight: 80,
              actions: <Widget>[
                IconButton(
                  iconSize: 25,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  tooltip: "Play/Pause",
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
                IconButton(
                  iconSize: 25,
                  icon: Icon(
                    isMusicOn == true ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                  ),
                  tooltip: "Volume",
                  onPressed: () {
                    setState(() {
                      isMusicOn == true
                          ? _controller.setVolume(0.0)
                          : _controller.setVolume(1.0);
                      isMusicOn = !isMusicOn;
                    });
                  },
                ),
                IconButton(
                  iconSize: 25,
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  tooltip: "Download",
                  onPressed: () {
                    // downloadController.downloadFile(
                    //     widget.url, path.basename(widget.url), widget.url);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 0),
          child: _controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    )));
  }

  void checkVideo() {
    setState(() {
      _progressValue = double.parse((_controller.value.position.inSeconds /
              _controller.value.duration.inSeconds)
          .toStringAsFixed(2));
    });

    if (_controller.value.isCompleted) {
      _controller.removeListener(checkVideo);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    downloadController.dispose();
    super.dispose();
  }
}
