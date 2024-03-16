package com.derdilla.blood_pressure_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val shareFolder = File(context.cacheDir, "share")
        if (shareFolder.exists()) shareFolder.deleteRecursively();

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, StorageProvider.CHANNEL)
            .setMethodCallHandler(StorageProvider(context, shareFolder))
    }
}
