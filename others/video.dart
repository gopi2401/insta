// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:insta/models/story_model.dart';
// import 'package:video_player/video_player.dart';

// import '../Functions/fileDownload.dart';

// class Video extends StatefulWidget {
//   const Video(
//       {super.key,
//       required this.data,
//       required this.carouselController,
//       required this.closer});
//   final StoriesJson data;
//   final InfiniteScrollController carouselController;
//   final bool closer;
//   @override
//   VideoState createState() => VideoState();
// }

// class VideoState extends State<Video> {
//   late VideoPlayerController _controller;
//   late FileDownload downloadController;
//   late double _progressValue;
//   bool isMusicOn = true;

//   @override
//   void initState() {
//     super.initState();
//     _progressValue = 0.0;
//     _controller = VideoPlayerController.networkUrl(Uri.parse(
//         widget.data.storie.isNotEmpty ? widget.data.storie : widget.data.img));
//     downloadController = Get.put(FileDownload());
//   }

//   Future<bool> started() async {
//     await _controller.initialize();
//     await _controller.play();
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Center(
//         child: Scaffold(
//           extendBodyBehindAppBar: true,
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(kToolbarHeight + 80),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   margin: const EdgeInsets.only(top: 35),
//                 ),
//                 const Padding(padding: EdgeInsets.only(top: 10, right: 5)),
//                 AppBar(
//                   flexibleSpace: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                       child: TweenAnimationBuilder(
//                         tween: Tween<double>(begin: 0, end: _progressValue),
//                         duration: const Duration(milliseconds: 500),
//                         builder: (context, value, child) {
//                           return LinearProgressIndicator(
//                             minHeight: 5,
//                             backgroundColor: Colors.white24,
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 Colors.white),
//                             value: value,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   title: const Text('',
//                       style: TextStyle(color: Colors.white, fontSize: 5)),
//                   toolbarHeight: 80,
//                   actions: <Widget>[
//                     IconButton(
//                       iconSize: 25,
//                       icon: Icon(
//                         _controller.value.isPlaying
//                             ? Icons.pause
//                             : Icons.play_arrow,
//                         color: Colors.white,
//                       ),
//                       tooltip: "Play/Pause",
//                       onPressed: () {
//                         setState(() {
//                           _controller.value.isPlaying
//                               ? _controller.pause()
//                               : _controller.play();
//                         });
//                       },
//                     ),
//                     IconButton(
//                       iconSize: 25,
//                       icon: Icon(
//                         isMusicOn ? Icons.volume_up : Icons.volume_off,
//                         color: Colors.white,
//                       ),
//                       tooltip: "Volume",
//                       onPressed: () {
//                         setState(() {
//                           isMusicOn
//                               ? _controller.setVolume(0.0)
//                               : _controller.setVolume(1.0);
//                           isMusicOn = !isMusicOn;
//                         });
//                       },
//                     ),
//                     IconButton(
//                       iconSize: 25,
//                       icon: const Icon(
//                         Icons.download,
//                         color: Colors.white,
//                       ),
//                       tooltip: "Download",
//                       onPressed: () {
//                         downloadController.downloadFile(
//                             widget.data.storie,
//                             widget.data.storie.split('?').first.split('/').last,
//                             widget.data.img);
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           body: Center(
//             child: Container(
//               padding: const EdgeInsets.only(top: 0),
//               child: FutureBuilder<bool>(
//                 future: started(),
//                 builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
//                   if (snapshot.data ?? false) {
//                     return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _controller.value.isPlaying
//                                 ? _controller.pause()
//                                 : _controller.play();
//                           });
//                         },
//                         child: AspectRatio(
//                           aspectRatio: _controller.value.aspectRatio,
//                           child: VideoPlayer(_controller),
//                         ));
//                   } else {
//                     return Image.network(
//                       widget.data.img,
//                       fit: BoxFit.fill,
//                       loadingBuilder: (BuildContext context, Widget child,
//                           ImageChunkEvent? loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Center(
//                           child: CircularProgressIndicator(
//                             value: loadingProgress.expectedTotalBytes != null
//                                 ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes!
//                                 : null,
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void checkVideo() {
//     if (_controller.value.isInitialized &&
//         _controller.value.duration.inSeconds > 0) {
//       setState(() {
//         _progressValue = _controller.value.position.inSeconds /
//             _controller.value.duration.inSeconds;
//       });
//     }

//     if (_controller.value.isCompleted) {
//       if (widget.closer) {
//         _controller.removeListener(checkVideo);
//         Navigator.of(context).pop();
//       } else {
//         widget.carouselController.nextItem();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     downloadController.dispose();
//     super.dispose();
//   }
// }
