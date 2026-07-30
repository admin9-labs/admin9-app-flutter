package com.admin9.app.foundation

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        if (BuildConfig.BUILD_TYPE == "release") {
            ReleasePluginRegistry.registerWith(flutterEngine)
            return
        }
        super.configureFlutterEngine(flutterEngine)
    }
}
