import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class to handle asset loading with proper error handling
class AssetHelper {
  /// Cache to store asset existence status
  static final Map<String, bool> _assetCache = {};

  /// Check if an asset exists
  static Future<bool> assetExists(String assetPath) async {
    if (_assetCache.containsKey(assetPath)) {
      return _assetCache[assetPath]!;
    }

    try {
      await rootBundle.load(assetPath);
      _assetCache[assetPath] = true;
      return true;
    } catch (e) {
      print('Asset not found: $assetPath - $e');
      _assetCache[assetPath] = false;
      return false;
    }
  }

  /// Build a profile avatar with proper fallback
  static Widget buildProfileAvatar({
    required double radius,
    String assetPath = 'images/profile.jpg',
    IconData fallbackIcon = Icons.person,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      child: ClipOval(
        child: FutureBuilder<bool>(
          future: assetExists(assetPath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: radius * 0.8,
                height: radius * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    iconColor ?? Colors.grey.shade600,
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              return Image.asset(
                assetPath,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Failed to load image asset: $assetPath - $error');
                  return Icon(
                    fallbackIcon,
                    size: radius,
                    color: iconColor ?? Colors.grey.shade600,
                  );
                },
              );
            }

            // Asset doesn't exist or failed to load
            return Icon(
              fallbackIcon,
              size: radius,
              color: iconColor ?? Colors.grey.shade600,
            );
          },
        ),
      ),
    );
  }

  /// Build an image with error handling
  static Widget buildImageWithFallback({
    required String assetPath,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
    IconData fallbackIcon = Icons.image_not_supported,
    Color? iconColor,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('Failed to load image: $assetPath - $error');

        if (fallbackWidget != null) {
          return fallbackWidget;
        }

        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(
            fallbackIcon,
            size: width * 0.5,
            color: iconColor ?? Colors.grey.shade400,
          ),
        );
      },
    );
  }

  /// Clear the asset cache (useful for hot reload)
  static void clearCache() {
    _assetCache.clear();
  }
}
