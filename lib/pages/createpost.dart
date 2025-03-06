import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gismultiinstancetestingenvironment/pages/newsfeed.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final supabase = Supabase.instance.client;

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_image == null ||
        _headerController.text.isEmpty ||
        _bodyController.text.isEmpty) {
      _showAlertDialog(
          'Error', 'Please fill in all fields and select an image.');
      return;
    }

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showAlertDialog('Error', 'User not authenticated.');
        return;
      }

      final fileName = const Uuid().v4();
      final storagePath = 'posts/$fileName.jpg';

      // Upload the image
      final uploadResponse = await supabase.storage
          .from('post-images')
          .upload(storagePath, _image!);

      print('Upload Response: $uploadResponse'); // Debug log

      // If uploadResponse is null or empty, fail gracefully
      if (uploadResponse == null || uploadResponse.isEmpty) {
        _showAlertDialog('Error', 'Image upload failed.');
        return;
      }

      // Get the public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('post-images').getPublicUrl(storagePath);

      print('Image URL: $imageUrl'); // Debug log

      // Insert the post into the database
      final response = await supabase.from('posts').insert({
        'user_id': userId,
        'post_header': _headerController.text,
        'post_body': _bodyController.text,
        'post_image_url': imageUrl,
        'area_coordinates': null, // Keeping this field blank
      });

      print('Insert Response: $response'); // Debug log

      // Check if insert was successful
      if (response == null ||
          (response is Map && response.containsKey('error'))) {
        _showAlertDialog(
          'Success',
          'Post uploaded successfully.',
          dismissible: true,
        );

        _headerController.clear();
        _bodyController.clear();
        setState(() => _image = null);

        // ✅ Navigate back to NewsFeed after success
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NewsFeed()),
          );
        });
      } else {
        _showAlertDialog(
          'Error',
          'An error occurred. Please try again.',
          dismissible: true,
        );

        _headerController.clear();
        _bodyController.clear();
        setState(() => _image = null);
      }
    } catch (e) {
      print('Upload Exception: $e');
      _showAlertDialog('Error', 'Failed to upload post: $e');
    }
  }

  void _showAlertDialog(String title, String message,
      {bool dismissible = false}) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _headerController,
              decoration: const InputDecoration(labelText: 'Post Header'),
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Post Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 150)
                : const Text('No image selected'),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _uploadPost,
              child: const Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}
