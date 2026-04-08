package com.example.tourist_safety_app_sih_pinnacle

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.tourist_safety_app_sih_pinnacle/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateSafetyStatus" -> {
                    val isProtected = call.argument<Boolean>("isProtected") ?: true
                    val prefs = getSharedPreferences(
                        SafetyWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE
                    )
                    prefs.edit()
                        .putBoolean(SafetyWidgetProvider.KEY_IS_PROTECTED, isProtected)
                        .apply()

                    // Broadcast to update all widget instances
                    SafetyWidgetProvider.updateAllWidgets(this)

                    result.success(true)
                }
                "getInitialRoute" -> {
                    val route = intent?.getStringExtra("route")
                    result.success(route)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Notify Flutter about the new route if launched from widget
        val route = intent.getStringExtra("route")
        if (route != null) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("navigateTo", route)
            }
        }
    }
}
