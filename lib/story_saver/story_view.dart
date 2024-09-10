import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:insta/story_saver/video.dart';

import '../models/story_model.dart';

class StoryView extends StatefulWidget {
  const StoryView({super.key, required this.stories});
  final Story stories;

  @override
  State<StoryView> createState() => StoryViewState();
}

class StoryViewState extends State<StoryView> {
  late InfiniteScrollController _controller;
  int selectedIndex = 0;
  double get screenWidth => MediaQuery.of(context).size.width;

  final double _anchor = 0.0;
  final bool _center = true;
  final double _velocityFactor = 1.0;
  double _itemExtent = 120;

  @override
  void initState() {
    super.initState();
    _controller = InfiniteScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemExtent = screenWidth - 2;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stories = widget.stories.stories;
    return Scaffold(
        body: SizedBox(
      // height: 200,
      child: InfiniteCarousel.builder(
        itemCount: stories.length,
        itemExtent: _itemExtent,
        center: _center,
        anchor: _anchor,
        velocityFactor: _velocityFactor,
        controller: _controller,
        itemBuilder: (context, itemIndex, realIndex) {
          final currentOffset = _itemExtent * realIndex;
          // stories data
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final diff = (_controller.offset - currentOffset);
              const maxPadding = 10.0;
              final carouselRatio = _itemExtent / maxPadding;
              return Padding(
                padding: EdgeInsets.only(
                  top: (diff / carouselRatio).abs(),
                  bottom: (diff / carouselRatio).abs(),
                ),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Video(
                data: stories[itemIndex],
              ),
            ),
          );
        },
      ),
    ));
  }
}
