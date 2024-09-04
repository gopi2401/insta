import 'package:permission_handler/permission_handler.dart';

class Permissions {
  // ignore: non_constant_identifier_names
  static Future storage_permission() async {
    // ignore: unused_local_variable
    var isDenied = await Permission.manageExternalStorage.isDenied;
    // ignore: unused_local_variable
    var permissionStatus = await Permission.storage.status;
    // if (permissionStatus.isDenied) {
    //   await Permission.storage.request();
    // } else if (permissionStatus.isPermanentlyDenied) {
    //   await openAppSettings();
    // }
    // if (isDenied) {
    //   var updatedPermissionStatus =
    //       await Permission.manageExternalStorage.request().isGranted;
    //   await Future.delayed(const Duration(seconds: 1));
    //   if (!updatedPermissionStatus) {
    //     await openAppSettings();
    //   }
    // }
  }
}
