package com.swiftshare.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.swiftshare/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "enableWifi" -> {
                    // TODO: Implement via WifiManager
                    result.success(false)
                }
                "enableBluetooth" -> {
                    // TODO: Implement via BluetoothAdapter
                    result.success(false)
                }
                "startWifiDirect" -> {
                    // TODO: Implement WiFi Direct discovery
                    result.success(false)
                }
                "getDeviceName" -> {
                    result.success(android.os.Build.MODEL)
                }
                else -> result.notImplemented()
            }
        }
    }
}
