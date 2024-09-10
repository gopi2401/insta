import 'package:path/path.dart' as path;

class Story {
  List<StoriesJson> stories;

  Story({required this.stories});

  Story.fromJson(Map<String, dynamic> json)
      : stories = (json['result'] as List<dynamic>)
            .map((storie) =>
                StoriesJson.fromJson(storie as Map<String, dynamic>))
            .toList();
}

class StoriesJson {
  String? fileName;
  String? img;
  String? storie;

  StoriesJson({
    required this.fileName,
    required this.img,
    required this.storie,
  });

  StoriesJson.fromJson(Map<String, dynamic> json) {
    img = json['image_versions2']['candidates'][0]['url'];
    storie = json['video_versions'][0]['url'];
    fileName = path.basename(storie!);
  }
}
