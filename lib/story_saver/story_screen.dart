import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insta/functions/file_download.dart';
import 'package:story_view/story_view.dart';

import '../models/story_model.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.stories});
  final Story stories;

  @override
  State<StoryScreen> createState() => StoryScreenState();
}

class StoryScreenState extends State<StoryScreen> {
  late final StoryController storyController;
  late FileDownload downloadController;
  bool isPlaying = true, isMusicOn = true;
  late int storyindex;

  @override
  void initState() {
    super.initState();
    storyController = StoryController();
    downloadController = Get.put(FileDownload());
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stories = widget.stories.stories;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          titleSpacing: 0,
          actions: [
            IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () {
                  var url = stories[storyindex].storie.isNotEmpty
                      ? stories[storyindex].storie
                      : stories[storyindex].img;
                  downloadController.downloadFile(
                      url,
                      url.split('?').first.split('/').last,
                      stories[storyindex].img);
                }),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: StoryView(
                storyItems: stories.isNotEmpty
                    ? stories.map((story) {
                        return story.storie.isNotEmpty
                            ? StoryItem.pageVideo(story.storie,
                                controller: storyController)
                            : StoryItem.pageImage(
                                url: story.img, controller: storyController);
                      }).toList()
                    : [
                        StoryItem.text(
                            title: "StoryItem not loaded!",
                            backgroundColor: Colors.blue)
                      ],
                onStoryShow: (storyItem, index) {
                  storyindex = index;
                },
                progressPosition:
                    ProgressPosition.top, // Disable default progress bar
                repeat: false,
                controller: storyController,
              ),
            ),
            // Positioned(
            //   top:
            //       kToolbarHeight, // This places the progress bar below the AppBar
            //   left: 0,
            //   right: 0,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //     child: StoryProgressIndicator(
            //       storyController: storyController,
            //       itemCount: stories.length,
            //       currentIndex: onStoryShowIndex,
            //     ),
            //   ),
            // ),
          ],
        ));
  }
}

// class StoryProgressIndicator extends StatelessWidget {
//   const StoryProgressIndicator({
//     super.key,
//     required this.storyController,
//     required this.itemCount,
//     required this.currentIndex,
//   });

//   final StoryController storyController;
//   final int itemCount;
//   final int currentIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: List.generate(
//         itemCount,
//         (index) {
//           return Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               height: 4,
//               decoration: BoxDecoration(
//                 color: index <= currentIndex ? Colors.white : Colors.grey[400],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
