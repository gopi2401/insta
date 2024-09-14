import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'utils/appdata.dart';

class IssueForm extends StatefulWidget {
  const IssueForm({super.key});

  @override
  _IssueFormState createState() => _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> createIssue(
      String title, String body, String? label, File? imageFile) async {
    List<String> labels = label != null ? [label] : ['bug'];

    String imageUrl = '';
    if (imageFile != null) {
      // Upload image to GitHub
      imageUrl = await uploadImageToGitHub(imageFile);
    }

    final issueBody =
        body + (imageUrl.isNotEmpty ? '\n\n![Screenshot]($imageUrl)' : '');

    final response = await http.post(
      Uri.parse('$githubApi/issues'),
      headers: {
        'Authorization': 'token $githubToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'body': issueBody,
        'labels': labels, // Optional: Labels for the issue
      }),
    );

    if (response.statusCode == 201) {
      // Success
      print('Issue created: ${jsonDecode(response.body)['html_url']}');
    } else {
      // Error handling
      print('Failed to create issue: ${response.statusCode}');
      print(response.body);
    }
  }

  Future<String> uploadImageToGitHub(File imageFile) async {
    final String base64Image = base64Encode(imageFile.readAsBytesSync());
    final String fileName = path.basename(imageFile.path);

    final response = await http.put(
      Uri.parse('$githubApi/contents/$fileName'),
      headers: {
        'Authorization': 'token $githubToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': 'Uploading screenshot',
        'content': base64Image,
        'branch': 'main',
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['content']['download_url'];
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return '';
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Issue Title'),
          ),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Issue Body'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => pickImage(),
            child: Text('Pick Screenshot'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text;
              final body = _bodyController.text;
              createIssue(title, body, null, _imageFile);
            },
            child: Text('Create Issue'),
          ),
        ],
      ),
    );
  }
}
