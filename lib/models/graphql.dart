class Graphql {
  List<FileJson>? files;

  Graphql({this.files});

  Graphql.fromJson(Map<String, dynamic> json) {
    files = <FileJson>[];
    if (json['graphql'] != null && json['graphql']['shortcode_media'] != null) {
      var media = json['graphql']['shortcode_media'];
      var fName = filename(media);
      if (media['__typename'] == 'GraphSidecar') {
        var arr = media['edge_sidecar_to_children']['edges'];
        arr.forEach((jso) {
          var n = "_" + jso['node']['id'].substring(15);
          files!.add(FileJson.fromJson(jso['node'], fName + n));
        });
      } else {
        files!.add(FileJson.fromJson(media, fName));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (files != null && files!.isNotEmpty) {
      data['graphql'] = {
        'shortcode_media': files![0].toJson(),
      };
    }
    return data;
  }
}

class FileJson {
  String? fileName;
  String? fileDisplayUrl;
  String? fileUrl;

  FileJson({
    required this.fileName,
    required this.fileDisplayUrl,
    required this.fileUrl,
  });

  FileJson.fromJson(Map<String, dynamic> json, String name) {
    fileDisplayUrl = json['display_url'];
    if (json['__typename'] == 'GraphVideo') {
      fileName = '$name.mp4';
      fileUrl = json['video_url'];
    } else if (json['__typename'] == 'GraphImage') {
      fileName = '$name.jpg';
      fileUrl = json['display_url'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = fileName;
    data['display_url'] = fileDisplayUrl;
    data['url'] = fileUrl;
    return data;
  }
}

String filename(Map<String, dynamic> json) {
  String name;
  if (json['edge_media_to_caption'] != null &&
      json['edge_media_to_caption']['edges'].isNotEmpty) {
    var text = json['edge_media_to_caption']['edges'][0]['node']['text']
        .toString()
        .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
        .replaceAll("\n", "_")
        .replaceAll("|", "_");
    name = text.length >= 60 ? text.substring(0, 60) : text;
  } else {
    name = json['id'].toString();
  }
  return name;
}
