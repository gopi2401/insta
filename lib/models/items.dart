class Items {
  List<FileJson>? files;

  Items({this.files});

  Items.fromJson(Map<String, dynamic> json) {
    files = <FileJson>[];
    if (json['items'] != null) {
      var media = json['items'][0];
      var fName = filename(media);
      if (media['carousel_media'] != null) {
        media['carousel_media'].forEach((jso) {
          var n = "_${jso['id'].substring(20)}";
          files!.add(FileJson.fromJson(jso, fName + n));
        });
      } else {
        files!.add(FileJson.fromJson(media, fName));
      }
    }
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
    fileDisplayUrl = json['image_versions2']['candidates'][0]['url'];
    if (json['image_versions2'] != null && json['video_versions'] != null) {
      fileName = '$name.mp4';
      fileUrl = json['video_versions'][0]['url'];
    } else if (json['image_versions2'] != null) {
      fileName = '$name.jpg';
      fileUrl = json['image_versions2']['candidates'][0]['url'];
    }
  }
}

String filename(Map<String, dynamic> json) {
  String name;
  if (json['caption'] != null && json['caption']['text'].trim().length > 0) {
    var text = json['caption']['text']
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
