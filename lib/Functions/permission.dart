import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future storage_permission() async {
    var isDenied = await Permission.manageExternalStorage.isDenied;
    var permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
      await Permission.storage.request();
    } else if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
    if (isDenied) {
      var updatedPermissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
      await Future.delayed(const Duration(seconds: 1));
      if (!updatedPermissionStatus) {
        await openAppSettings();
      }
    }
  }
}
