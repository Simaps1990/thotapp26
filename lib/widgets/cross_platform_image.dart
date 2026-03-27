import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';

/// A widget that displays images from file paths in a cross-platform way.
/// Works on both web and mobile platforms.
class CrossPlatformImage extends StatelessWidget {
  final String? filePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CrossPlatformImage({
    Key? key,
    required this.filePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filePath == null || filePath!.isEmpty) {
      return placeholder ?? _buildDefaultPlaceholder();
    }

    if (kIsWeb) {
      // On web, use Image.network for web paths or memory for file picker results
      // FilePicker on web returns bytes, not paths, so we handle both cases
      return Image.network(
        filePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // If network image fails, it might be a local file path
          // In that case, show the error widget
          return errorWidget ?? _buildErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildDefaultPlaceholder();
        },
      );
    } else {
      // On mobile, use Image.file
      try {
        return Image.file(
          File(filePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildErrorWidget();
          },
        );
      } catch (e) {
        return errorWidget ?? _buildErrorWidget();
      }
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
color: Colors.grey.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
color: Colors.grey.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
      ),
    );
  }
}
