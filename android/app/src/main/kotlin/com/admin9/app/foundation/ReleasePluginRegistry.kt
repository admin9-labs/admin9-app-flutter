package com.admin9.app.foundation

import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin

internal object ReleasePluginRegistry {
    private const val tag = "ReleasePluginRegistry"

    fun registerWith(flutterEngine: FlutterEngine) {
        register(
            flutterEngine = flutterEngine,
            pluginName = "shared_preferences_android",
            plugin = SharedPreferencesPlugin(),
        )
    }

    private fun register(
        flutterEngine: FlutterEngine,
        pluginName: String,
        plugin: FlutterPlugin,
    ) {
        try {
            flutterEngine.plugins.add(plugin)
        } catch (exception: Exception) {
            Log.e(tag, "Could not register $pluginName", exception)
        }
    }
}
