import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/appdata.dart';

class IssueForm extends StatefulWidget {
  const IssueForm({super.key});

  @override
  IssueFormState createState() => IssueFormState();
}

class IssueFormState extends State<IssueForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String option = 'Issue';

  Future<void> createIssue(
      String title, String body, String? label, File? imageFile) async {
    List<String> labels = label == 'Issue'
        ? ['bug']
        : label == 'Suggestion'
            ? ['ui']
            : ['bug'];

    String imageUrl = '';
    if (imageFile != null) {
      // Upload image to GitHub
      imageUrl = await uploadImageToGitHub(imageFile);
    }

    final issueBody = body +
        (imageUrl.isNotEmpty ? '\n\n![Screenshot]($imageUrl)' : '') +
        (_nameController.text.isNotEmpty
            ? '\n\n$option raised by ${_nameController.text.trim()}.'
            : '');

    final response = await http.post(
      Uri.parse('$githubApi/issues'),
      headers: {
        'Authorization': 'token ${dotenv.env['githubToken']}',
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
      String issueUrl = jsonDecode(response.body)['html_url'];

      // Clear inputs
      _nameController.clear();
      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _imageFile = null;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text('Issue created: $issueUrl'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
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
        'Authorization': 'token ${dotenv.env['githubToken']}',
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
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose the any option',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: option, // Set the initial value
              items: <String>['Issue', 'Suggestion'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  option = newValue!;
                });
              },
            ),
            const Text(
              'Your Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            Text(
              '$option Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter ${option.toLowerCase()} title',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$option Body',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                hintText: 'Enter ${option.toLowerCase()} body',
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('Pick Screenshot'),
                ),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      _imageFile!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                final title = _titleController.text;
                final body = _bodyController.text;
                if (title.isNotEmpty && body.isNotEmpty) {
                  await createIssue(title, body, option, _imageFile);
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Send $option'),
            ),
          ],
        ),
      ),
    );
  }
}
