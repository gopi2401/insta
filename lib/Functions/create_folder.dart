import 'dart:io';

class AppUtil {
  static Future<String> createFolder() async {
    final Directory _appDocDirFolder = Directory('/storage/emulated/0/insta/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
}
