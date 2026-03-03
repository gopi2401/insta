import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:insta/core/services/feedback_service.dart';

class IssueForm extends StatefulWidget {
  const IssueForm({super.key});

  @override
  State<IssueForm> createState() => _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool isLoading = false;
  FeedbackCategory category = FeedbackCategory.issue;

  FeedbackService get feedbackService {
    if (!Get.isRegistered<FeedbackService>()) {
      Get.put(FeedbackService(), permanent: true);
    }
    return FeedbackService.to;
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    setState(() {
      _imageFile = picked != null ? File(picked.path) : null;
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final issueUrl = await feedbackService.createIssue(
        title: title,
        body: body,
        category: category,
        reporter: _nameController.text.trim(),
        screenshot: _imageFile,
      );
      if (!mounted) return;
      _nameController.clear();
      _titleController.clear();
      _bodyController.clear();
      setState(() => _imageFile = null);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: Text('Issue created: ${issueUrl ?? 'N/A'}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
      appBar: AppBar(title: const Text('Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose an option',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<FeedbackCategory>(
              value: category,
              items: const [
                DropdownMenuItem(
                  value: FeedbackCategory.issue,
                  child: Text('Issue'),
                ),
                DropdownMenuItem(
                  value: FeedbackCategory.suggestion,
                  child: Text('Suggestion'),
                ),
              ],
              onChanged: (newValue) {
                if (newValue == null) return;
                setState(() => category = newValue);
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${category == FeedbackCategory.issue ? 'Issue' : 'Suggestion'} Title',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${category == FeedbackCategory.issue ? 'Issue' : 'Suggestion'} Body',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                hintText: 'Enter details',
                border: OutlineInputBorder(),
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
                    child: Image.file(_imageFile!, height: 100, fit: BoxFit.cover),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Send ${category == FeedbackCategory.issue ? 'Issue' : 'Suggestion'}',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


