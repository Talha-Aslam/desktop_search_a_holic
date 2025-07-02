import 'package:flutter/services.dart';

class WindowManager {
  static const MethodChannel _channel = MethodChannel('window_manager');

  static Future<void> exitFullScreen() async {
    try {
      await _channel.invokeMethod('exitFullScreen');
      print('✅ Successfully exited windowed full screen');
    } catch (e) {
      print('❌ Failed to exit windowed full screen: $e');
      rethrow;
    }
  }

  static Future<void> toggleFullScreen() async {
    try {
      await _channel.invokeMethod('toggleFullScreen');
      print('✅ Successfully toggled windowed full screen');
    } catch (e) {
      print('❌ Failed to toggle windowed full screen: $e');
      rethrow;
    }
  }

  static Future<bool> isFullScreen() async {
    try {
      final result = await _channel.invokeMethod('isFullScreen');
      return result ?? true;
    } catch (e) {
      print('❌ Failed to get full screen state: $e');
      return true;
    }
  }
}
