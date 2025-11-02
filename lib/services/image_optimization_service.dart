import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Service d'optimisation des images avec caching intelligent
class ImageOptimizationService {
  static final Map<String, ui.Image?> _imageCache = {};
  static const int maxCacheSize = 20; // Limite de cache

  /// Précharge une image dans le cache
  static Future<void> precacheOptimizedImage(String path, BuildContext context) async {
    if (_imageCache.containsKey(path)) {
      return; // Déjà en cache
    }

    try {
      final ImageProvider provider = AssetImage(path);
      await precacheImage(provider, context);
      print('[ImageOptimization] ✅ Image précachée: $path');
    } catch (e) {
      print('[ImageOptimization] ❌ Erreur précache: $e');
    }
  }

  /// Nettoie le cache si nécessaire
  static void cleanCache() {
    if (_imageCache.length > maxCacheSize) {
      print(
          '[ImageOptimization] 🧹 Nettoyage cache (${_imageCache.length} items)');
      _imageCache.clear();
    }
  }

  /// Obtient une image du cache
  static ui.Image? getCachedImage(String path) {
    return _imageCache[path];
  }
}

/// Widget optimisé pour le chargement d'images
class OptimizedImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const OptimizedImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.grey[600],
            size: 32,
          ),
        );
      },
      cacheWidth: width != null
          ? (width! * MediaQuery.of(context).devicePixelRatio).toInt()
          : null,
      cacheHeight: height != null
          ? (height! * MediaQuery.of(context).devicePixelRatio).toInt()
          : null,
    );
  }
}

/// Widget pour lazy loading d'images dans une liste
class LazyImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LazyImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Délai de chargement pour lazy loading
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
    }

    return OptimizedImage(
      path: widget.path,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
