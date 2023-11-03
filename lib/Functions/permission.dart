// import 'package:permission_handler/permission_handler.dart';

// class permissions {
//   static Future storage_permission() async {
//     var isDenied = await Permission.manageExternalStorage.isDenied;

//     if (isDenied) {
//       // Here, ask for the permission for the first time
//       final updatedPermissionStatus =
//           await Permission.manageExternalStorage.request().isGranted;

//       // Add a delay to give the user time to respond to the request
//       await Future.delayed(
//           Duration(seconds: 1)); // You can adjust the delay time as needed

//       if (!updatedPermissionStatus) {
//         // User denied the permission again, navigate to app settings
//         await openAppSettings();
//       }
//     } else {
//       // Permission is granted, you can now do what you need
//       // Do stuff that require permission here
//     }
//   }
// }
