import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

const int maxImageSize = 750; // Fixed height of 750px

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<File> _selectedFiles = [];
  String? _userId;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  double _uploadProgress = 0;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('userId');
      setState(() {
        _userId = savedUserId;
      });
    } catch (e) {
      debugPrint("Error checking session: $e");
    }
  }

  /// Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxHeight: maxImageSize.toDouble(),
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        List<File> validFiles = [];

        for (var pickedFile in pickedFiles) {
          final file = File(pickedFile.path);
          final stat = await file.stat();

          // Check file size (max 5MB)
          if (stat.size > 5 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${pickedFile.name} is too large (max 5MB)"),
              ),
            );
            continue;
          }

          // Check file type
          final extension = pickedFile.path.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${pickedFile.name} unsupported format")),
            );
            continue;
          }

          validFiles.add(file);
        }

        setState(() {
          _selectedFiles = validFiles;
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error selecting images")));
    }
  }

  /// Process image to fixed height of 750px
  Future<Uint8List> _processImage(File file) async {
    try {
      final originalBytes = await file.readAsBytes();
      final image = img.decodeImage(originalBytes);
      if (image == null) return originalBytes;

      final aspectRatio = image.width / image.height;
      final newHeight = maxImageSize;
      final newWidth = (maxImageSize * aspectRatio).toInt();

      final resized = img.copyResize(image, width: newWidth, height: newHeight);
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (e) {
      debugPrint("Error processing image: $e");
      return await file.readAsBytes();
    }
  }

  /// Upload multiple images
  Future<void> uploadImages(List<File> files) async {
    if (_userId == null) throw Exception("User not logged in");

    setState(() {
      _uploadProgress = 0;
      _isUploading = true;
      _uploadError = null;
    });

    try {
      List<Map<String, dynamic>> imageRefs = [];
      double step = 1 / (files.length + 1);

      for (int i = 0; i < files.length; i++) {
        final file = files[i];

        final bytes = await _processImage(file);
        final imageData = base64Encode(bytes);

        final filesId = FirebaseFirestore.instance
            .collection('photos')
            .doc()
            .id;

        await FirebaseFirestore.instance.collection('photos').doc(filesId).set({
          'files_id': filesId,
          'filetype': 'jpg',
          'data': imageData,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'user_id': _userId,
        });

        imageRefs.add({'files_id': filesId, 'filetype': 'jpg'});

        setState(() {
          _uploadProgress = (i + 1) * step;
        });
      }

      // Save post metadata with all images
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': _userId,
        'description': _descriptionController.text.trim(),
        'uploadDate': DateTime.now().toUtc().toIso8601String(),
        'images': imageRefs, // multiple images
      });

      setState(() {
        _uploadProgress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("Error uploading: $e");
      setState(() {
        _uploadError = "Failed to upload: ${e.toString()}";
      });
      rethrow;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _submitPost() async {
    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select images")));
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please add a description")));
      return;
    }

    try {
      await uploadImages(_selectedFiles);
      setState(() {
        _selectedFiles = [];
        _descriptionController.clear();
        _uploadProgress = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading images: $e")));
    }
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
      _uploadError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Post"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: _isUploading
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancelUpload,
                  tooltip: "Cancel upload",
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_uploadError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _uploadError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_isUploading) ...[
                const Text(
                  "Uploading...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text(
                  "${(_uploadProgress * 100).toStringAsFixed(1)}%",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Select Images"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading || _selectedFiles.isEmpty
                          ? null
                          : _submitPost,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Upload Post"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedFiles.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text("No images selected", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selected Images",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedFiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedFiles[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
