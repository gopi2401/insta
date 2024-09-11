import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class Permissions {
  static Future<void> requestStoragePermission(BuildContext context) async {
    // Get phone SDK version first in order to request correct permissions.
    int? androidSDK;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    androidSDK = androidInfo.version.sdkInt;

    if (androidSDK >= 30) {
      // Check first if we already have the permissions
      final currentStatusManaged =
          await Permission.manageExternalStorage.status;
      if (currentStatusManaged.isDenied) {
        final requestStatusManaged =
            await Permission.manageExternalStorage.request();
        if (requestStatusManaged.isDenied) {
          // Show a dialog if permission is denied
          showPermissionDeniedDialog(context);
        }
      }
    } else {
      // For older phones, simply request the typical storage permissions
      final currentStatusStorage = await Permission.storage.status;
      if (currentStatusStorage.isDenied) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          showPermissionDeniedDialog(context);
        }
      }
    }
  }

  static void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SimpleDialog(
            children: <Widget>[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Permission Denied',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      const Text(
                        'Something went wrong, app not working properly',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      MaterialButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
