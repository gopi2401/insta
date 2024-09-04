import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:insta/status_saver/ui/dashboard.dart';
import 'package:permission_handler/permission_handler.dart';

class WhatsApp extends StatefulWidget {
  const WhatsApp({Key? key}) : super(key: key);
  @override
  WhatsAppState createState() => WhatsAppState();
}

class WhatsAppState extends State<WhatsApp> {
  int? _storagePermissionCheck;
  Future<int>? _storagePermissionChecker;

  int? androidSDK;
  Future<int> _loadPermission() async {
    //Get phone SDK version first inorder to request correct permissions.

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      androidSDK = androidInfo.version.sdkInt;
    });
    //
    if (androidSDK! >= 30) {
      //Check first if we already have the permissions
      final currentStatusManaged =
          await Permission.manageExternalStorage.status;
      if (currentStatusManaged.isGranted) {
        //Update
        return 1;
      } else {
        return 0;
      }
    } else {
      //For older phones simply request the typical storage permissions
      //Check first if we already have the permissions
      final currentStatusStorage = await Permission.storage.status;
      if (currentStatusStorage.isGranted) {
        //Update provider
        return 1;
      } else {
        return 0;
      }
    }
  }

  Future<int> requestPermission() async {
    if (androidSDK! >= 30) {
      //request management permissions for android 11 and higher devices
      final requestStatusManaged =
          await Permission.manageExternalStorage.request();
      //Update Provider model
      if (requestStatusManaged.isGranted) {
        return 1;
      } else {
        return 0;
      }
    } else {
      final requestStatusStorage = await Permission.storage.request();
      //Update provider model
      if (requestStatusStorage.isGranted) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  Future<int> requestStoragePermission() async {
    /// PermissionStatus result = await
    /// SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    final result = await [Permission.storage].request();
    setState(() {});
    if (result[Permission.storage]!.isDenied) {
      return 0;
    } else if (result[Permission.storage]!.isGranted) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _storagePermissionChecker = (() async {
      int storagePermissionCheckInt;
      int finalPermission;

      if (_storagePermissionCheck == null || _storagePermissionCheck == 0) {
        _storagePermissionCheck = await _loadPermission();
      } else {
        _storagePermissionCheck = 1;
      }
      if (_storagePermissionCheck == 1) {
        storagePermissionCheckInt = 1;
      } else {
        storagePermissionCheckInt = 0;
      }

      if (storagePermissionCheckInt == 1) {
        finalPermission = 1;
      } else {
        finalPermission = 0;
      }

      return finalPermission;
    })();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: const Text('Status Saver'),
            backgroundColor: const Color(0xff128C7E),
            bottom: TabBar(tabs: [
              Container(
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                  'IMAGES',
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                  'VIDEOS',
                ),
              ),
            ]),
          ),
          body: const Dashboard(),
          floatingActionButton: TextButton(
            child: const Text(
              'Allow Storage Permission',
              style: TextStyle(fontSize: 20.0),
            ),
            onPressed: () {
              _storagePermissionChecker = requestPermission();
              setState(() {});
            },
          ),
        ));
  }
}
