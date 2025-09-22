import 'dart:convert';

import 'package:everesports/database/config/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:everesports/widget/common_snackbar.dart';

class StoryUploadPage extends StatefulWidget {
  const StoryUploadPage({Key? key}) : super(key: key);

  @override
  _StoryUploadPageState createState() => _StoryUploadPageState();
}

class _StoryUploadPageState extends State<StoryUploadPage> {
  String? _userId;
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      commonSnackBarbuildError(
        context,
        'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Future<dynamic> _getCurrentPosition() async {
    // TODO: Uncomment and use geolocator when available
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   await Geolocator.openLocationSettings();
    //   return Future.error('Location services are disabled.');
    // }
    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     return Future.error('Location permissions are denied');
    //   }
    // }
    // if (permission == LocationPermission.deniedForever) {
    //   return Future.error('Location permissions are permanently denied.');
    // }
    // return await Geolocator.getCurrentPosition();
    return null;
  }

  Future<void> _uploadStory() async {
    if (_userId == null ||
        _descriptionController.text.trim().isEmpty ||
        _imageFile == null) {
      commonSnackBarbuildError(
        context,
        'Please fill all fields and select an image',
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Check if a story exists for today
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final storiesCol = db.collection('stories');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayT00 = '${today}T00:00:00.000';
      final todayT23 = '${today}T23:59:59.999';
      final existing = await storiesCol.findOne({
        'userId': _userId,
        'uploadTime': {'\$gte': todayT00, '\$lte': todayT23},
      });
      await db.close();
      if (existing != null) {
        commonSnackBarbuildError(
          context,
          'You can only upload one story per day.',
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }
      final now = DateTime.now();
      final position = await _getCurrentPosition();

      final uri = Uri.parse('$fileServerBaseUrl/api/stories');
      final request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['userId'] = _userId!;
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['uploadTime'] = now.toIso8601String();
      request.fields['location'] = jsonEncode({
        'latitude': position?.latitude,
        'longitude': position?.longitude,
      });

      // Add image file
      final mimeType = lookupMimeType(_imageFile!.path) ?? 'image/jpeg';
      final fileExtension = mimeType.split('/')[1];

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        commonSnackBarbuildSuccess(context, 'Story uploaded successfully');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final error = jsonDecode(responseBody);
        commonSnackBarbuildError(
          context,
          error['message'] ?? 'Failed to upload story',
        );
      }
    } catch (e) {
      commonSnackBarbuildError(context, 'Failed to upload story: $e');
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _isUploading ? null : _uploadStory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'What\'s happening?',
                      ),
                      maxLines: 5,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 20),
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadStory,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Story'),
            ),
          ],
        ),
      ),
    );
  }
}
