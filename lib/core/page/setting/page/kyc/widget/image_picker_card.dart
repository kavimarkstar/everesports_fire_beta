import 'dart:io';

import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? selectedFile;
  final ValueChanged<File?> onImageSelected;
  final double height;

  const ImagePickerCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.selectedFile,
    required this.onImageSelected,
    this.height = 120,
  });

  Future<void> _showImagePicker(BuildContext context) async {
    final file = await showModalBottomSheet<File>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                Navigator.pop(ctx, image != null ? File(image.path) : null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                Navigator.pop(ctx, image != null ? File(image.path) : null);
              },
            ),
          ],
        ),
      ),
    );

    if (file != null) {
      onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actualHeight = selectedFile != null ? 200.0 : height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () => _showImagePicker(context),
        child: Container(
          width: double.infinity,
          height: actualHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(5),
            color: Colors.transparent,
          ),
          child: selectedFile != null
              ? _buildImagePreview(context)
              : _buildPlaceholder(context, isDark),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.file(
            selectedFile!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => _showImagePicker(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 48, color: mainColor),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? mainWhiteColor : mainBlackColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class DocumentImagePicker extends StatelessWidget {
  final String documentType;
  final File? frontImage;
  final File? backImage;
  final ValueChanged<File?> onFrontImageSelected;
  final ValueChanged<File?> onBackImageSelected;
  final bool isRequired;

  const DocumentImagePicker({
    super.key,
    required this.documentType,
    this.frontImage,
    this.backImage,
    required this.onFrontImageSelected,
    required this.onBackImageSelected,
    this.isRequired = true,
  });

  String get _frontTitle {
    switch (documentType.toLowerCase()) {
      case 'passport':
        return 'Passport Photo Page';
      case 'national id':
        return 'ID Card Front';
      case 'driving license':
        return 'License Front';
      default:
        return 'Document Front';
    }
  }

  String get _backTitle {
    switch (documentType.toLowerCase()) {
      case 'passport':
        return 'Passport Back/Info Page';
      case 'national id':
        return 'ID Card Back';
      case 'driving license':
        return 'License Back';
      default:
        return 'Document Back';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Attach $documentType Documents',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Both front and back sides recommended for faster verification',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),

        // Front side
        ImagePickerCard(
          title: _frontTitle,
          subtitle: 'Tap to select front image',
          selectedFile: frontImage,
          onImageSelected: onFrontImageSelected,
        ),

        // Back side
        ImagePickerCard(
          title: _backTitle,
          subtitle: 'Tap to select back image (optional)',
          selectedFile: backImage,
          onImageSelected: onBackImageSelected,
        ),

        // Helper text
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ensure documents are clear, well-lit, and all text is readable',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
