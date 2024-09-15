class Story {
  List<StoriesJson> stories;

  Story({required this.stories});

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      stories: (json['result'] as List<dynamic>)
          .map((storie) => StoriesJson.fromJson(storie as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StoriesJson {
  String img;
  String storie;
  String pk;

  StoriesJson({
    required this.img,
    required this.storie,
    required this.pk,
  });

  factory StoriesJson.fromJson(Map<String, dynamic> json) {
    return StoriesJson(
      img: json['image_versions2'] != null &&
              json['image_versions2']['candidates'] is List
          ? json['image_versions2']['candidates'][0]['url'] ?? ''
          : '',
      storie: json['video_versions'] != null && json['video_versions'] is List
          ? json['video_versions'][0]['url'] ?? ''
          : '',
      pk: json['pk'] != null ? json['pk'] ?? '' : '',
    );
  }
}
