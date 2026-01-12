package com.example.kfc

import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.kfc/notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSound" -> {
                    playNotificationSound()
                    result.success(null)
                }
                "flashScreen" -> {
                    flashScreen()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playNotificationSound() {
        try {
            // Lấy notification sound mặc định của hệ thống
            val notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val ringtone = RingtoneManager.getRingtone(applicationContext, notification)
            ringtone.play()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun flashScreen() {
        try {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            
            // Flash: tắt -> bật -> tắt
            val originalBrightness = window.attributes.screenBrightness
            
            window.attributes = window.attributes.apply {
                screenBrightness = 1.0f // Tối đa
            }
            
            // Đợi 200ms
            Thread.sleep(200)
            
            // Trở về bình thường
            window.attributes = window.attributes.apply {
                screenBrightness = originalBrightness
            }
            
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
