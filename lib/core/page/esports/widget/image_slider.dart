import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class AutoImageSlider extends StatefulWidget {
  /// Accepts a list of image data, which can be either:
  /// - a base64 string (binary image data, e.g. "iVBORw0KGgoAAAANS...")
  /// - a network URL (http/https)
  /// The widget will auto-detect and display accordingly.
  final List<String>? imageDataList;
  final double height;
  final Duration interval;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AutoImageSlider({
    super.key,
    this.imageDataList,
    this.height = 200,
    this.interval = const Duration(seconds: 3),
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<AutoImageSlider> createState() => _AutoImageSliderState();
}

class _AutoImageSliderState extends State<AutoImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<String> _images;
  late final Duration _interval;
  bool _disposed = false;

  static const List<String> _sampleImages = [
    // These are network URLs for fallback
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _images = (widget.imageDataList == null || widget.imageDataList!.isEmpty)
        ? _sampleImages
        : widget.imageDataList!;
    _interval = widget.interval;
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  Future<void> _startAutoSlide() async {
    while (!_disposed && _images.length > 1) {
      await Future.delayed(_interval);
      if (_disposed) break;
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _images.length;
      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String data) {
    // If the string looks like a URL, use Image.network
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return Image.network(
        data,
        fit: widget.fit,
        width: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.5 : 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator.adaptive(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        (progress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
        ),
      );
    }

    // Otherwise, treat as base64-encoded image data
    try {
      Uint8List bytes = base64Decode(data);
      return Image.memory(
        bytes,
        fit: widget.fit,
        width: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.5 : 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
        ),
      );
    } catch (e) {
      // If decoding fails, show error icon
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.redAccent,
            size: 40,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 40, color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            height: isDesktop(context) ? 400 : widget.height,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final data = _images[index];
                  return _buildImage(data);
                },
              ),
            ),
          ),
          if (_images.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: List.generate(_images.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
