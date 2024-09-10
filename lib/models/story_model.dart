import 'package:path/path.dart' as path;

class Story {
  List<StoriesJson>? stories;

  Story({this.stories});

  Story.fromJson(Map<String, dynamic> json) {
    stories = <StoriesJson>[];
    if (json['result'].length != 0) {
      for (var storie in json['result']) {
        storie.add(StoriesJson.fromJson(storie));
      }
    }
  }

  get length => null;
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
    var url = storie = json['video_versions'][0]['url'];
    fileName = path.basename(url);
  }
}
