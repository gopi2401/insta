// MainActivity.kt or any other suitable Kotlin file in your Android project

package com.example.insta

import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MMvtActivityy : FlutterActivity() {

    private val CHANNEL = "com.example.insta/app_version"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            if (call.method == "getAppVersion") {
                val versionName = getAppVersion()
                result.success(versionName)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAppVersion(): String {
        try {
            val pInfo = packageManager.getPackageInfo(packageName, 0)
            return pInfo.versionName
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
        return "Unknown"
    }
}
