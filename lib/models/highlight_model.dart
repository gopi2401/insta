class Highlight {
  List<HighlightInfo> highlights;

  Highlight({required this.highlights});

  // Named constructor for JSON deserialization
  Highlight.fromJson(Map<String, dynamic> json)
      : highlights = (json['result'] as List<dynamic>)
            .map((highlight) =>
                HighlightInfo.fromJson(highlight as Map<String, dynamic>))
            .toList();

  // Method to convert the class object to JSON
  Map<String, dynamic> toJson() {
    return {
      'result': highlights.map((highlight) => highlight.toJson()).toList(),
    };
  }
}

class HighlightInfo {
  String id;
  String title;
  String coverMedia;

  // Constructor
  HighlightInfo({
    required this.id,
    required this.title,
    required this.coverMedia,
  });

  // Named constructor for JSON deserialization
  factory HighlightInfo.fromJson(Map<String, dynamic> json) {
    return HighlightInfo(
      id: json['id'] ?? '0',
      title: json['title'] ?? 'Unknown',
      coverMedia: json['cover_media']?['cropped_image_version']?['url'] ?? '',
    );
  }

  // Method to convert the class object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_media': coverMedia,
    };
  }
}
