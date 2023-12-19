package com.example.insta

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    private var sharedText: String? = null
    private val CHANNEL = "app.channel.shared.data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        val action = intent.action
        val type = intent.type

        if (Intent.ACTION_SEND == action && type != null) {
            if ("text/plain" == type) {
                handleSendText(intent) // Handle text being sent
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    private fun handleSendText(intent: Intent) {
        sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        if (sharedText != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("getSharedText", sharedText)
        }
    }
}
