import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:flutter/material.dart';

class FirebaseCustomCropperPage extends StatefulWidget {
  final Uint8List imageBytes;
  final bool isProfile;
  final Future<String?> Function(Uint8List) uploadCallback;

  const FirebaseCustomCropperPage({
    super.key,
    required this.imageBytes,
    required this.isProfile,
    required this.uploadCallback,
  });

  @override
  State<FirebaseCustomCropperPage> createState() =>
      _FirebaseCustomCropperPageState();
}

class _FirebaseCustomCropperPageState extends State<FirebaseCustomCropperPage> {
  final CropController _controller = CropController();
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      _controller.crop();
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = '${getErrorCroppingImage(context)} $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${getCrop(context)} ${widget.isProfile ? getProfile(context) : getCover(context)} ${getImage(context)}',
        ),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _controller,
              aspectRatio: widget.isProfile ? 1 : 16 / 9,
              onCropped: (result) async {
                if (!_isProcessing) return;
                try {
                  // Success case: result has a 'croppedImage' or 'image' field
                  if (result.toString().contains('Success')) {
                    final croppedImage =
                        (result as dynamic).croppedImage ??
                        (result as dynamic).image;
                    final imageUrl = await widget.uploadCallback(croppedImage);
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      if (!mounted) return;
                      Navigator.of(context).pop(imageUrl);
                    } else {
                      setState(() {
                        _errorMessage = getFailedToUploadImage(context);
                        _isProcessing = false;
                      });
                    }
                  } else if (result.toString().contains('Error')) {
                    final error =
                        (result as dynamic).error ?? getUnknownError(context);
                    setState(() {
                      _errorMessage =
                          '${getErrorCroppingImage(context)} $error';
                      _isProcessing = false;
                    });
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = '${getErrorUploadingImage(context)} $e';
                    _isProcessing = false;
                  });
                }
              },
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),

            child: commonElevatedButtonbuild(
              context,
              getUpload(context),
              _isProcessing ? null : _processImage,
            ),
          ),
        ],
      ),
    );
  }
}
