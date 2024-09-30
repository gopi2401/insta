import 'dart:io';

class AppUtil {
  static Future<String> createFolder() async {
    final Directory appDocDirFolder = Directory('/storage/emulated/0/insta/');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }
}
