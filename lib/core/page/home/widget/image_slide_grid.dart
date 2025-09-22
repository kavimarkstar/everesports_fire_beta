import 'dart:convert';
import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ImageSlideGrid extends StatefulWidget {
  final List<String> imageBase64List;

  final double borderRadius;

  ImageSlideGrid({
    Key? key,
    required this.imageBase64List,

    this.borderRadius = 12,
  }) : super(key: key);

  @override
  _ImageSlideGridState createState() => _ImageSlideGridState();
}

class _ImageSlideGridState extends State<ImageSlideGrid> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _moveTo(int index) {
    if (index >= 0 && index < widget.imageBase64List.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _moveNext() {
    if (_currentIndex < widget.imageBase64List.length - 1) {
      _moveTo(_currentIndex + 1);
    }
  }

  void _movePrev() {
    if (_currentIndex > 0) {
      _moveTo(_currentIndex - 1);
    }
  }

  bool get _isDesktop {
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageBase64List.where((e) => e.isNotEmpty).toList();

    if (images.isEmpty) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.red, size: 48),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SizedBox(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.memory(
                        base64Decode(images[index]),
                        fit: BoxFit.fitHeight,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isDesktop && images.length > 1)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.chevron_left, size: 32),
                        color: _currentIndex > 0
                            ? Colors.black.withOpacity(0.7)
                            : Colors.grey[400],
                        onPressed: _currentIndex > 0 ? _movePrev : null,
                        splashRadius: 24,
                        tooltip: 'Previous image',
                      ),
                    ),
                  ),
                if (_isDesktop && images.length > 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.chevron_right, size: 32),
                        color: _currentIndex < images.length - 1
                            ? Colors.black.withOpacity(0.7)
                            : Colors.grey[400],
                        onPressed: _currentIndex < images.length - 1
                            ? _moveNext
                            : null,
                        splashRadius: 24,
                        tooltip: 'Next image',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 8 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? mainColor
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
