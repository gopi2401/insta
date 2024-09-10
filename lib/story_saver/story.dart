import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:insta/story_saver/video.dart';

class Story extends StatefulWidget {
  const Story({super.key, required this.stories});
  final stories;

  @override
  State<Story> createState() => StoryState();
}

class StoryState extends State<Story> {
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
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stories = widget.stories;
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
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Video(
                url:
                    'https://instagram.fcxh3-1.fna.fbcdn.net/o1/v/t16/f2/m69/An_U2UZbOewsBHi1l5_3CSXCaOf7qVjmrHAddinJ4846DmQzbJpxIeqGy-nt4RECCONgvpkt1tsPUXoVqE2DqRIQ.mp4?stp=dst-mp4&efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uc3RvcnkuYzIuMTA4MC5iYXNlbGluZSJ9&_nc_cat=106&vs=390367200542388_2712838159&_nc_vs=HBksFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HRUp0ZkFKaXozb0FUeGNEQU0xN0h5dk1pWHhOYnBSMUFBQUYVAALIAQAVAhg6cGFzc3Rocm91Z2hfZXZlcnN0b3JlL0dCMjFYQnRPMXUxdV80d0dBT2hvaWVPUHFpbDRicGt3QUFBRhUCAsgBACgAGAAbAYgHdXNlX29pbAExFQAAJsSs%2Fs%2F2zIRAFQIoAkMzLBdAK0UeuFHrhRgWZGFzaF9iYXNlbGluZV8xMDgwcF92MREAdegHAA%3D%3D&_nc_rid=2fe9d664df&ccb=9-4&oh=00_AYCckxFDLArX7m5IRi96kzNfmM9kS6MMnmMlnlFDDim86A&oe=66E07433&_nc_sid=982cc7',
                name: '',
              ),
            ),
          );
        },
      ),
    ));
  }
}
