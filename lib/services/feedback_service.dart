import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../utils/appdata.dart';

enum FeedbackCategory { issue, suggestion }

class FeedbackService extends GetxService {
  static FeedbackService get to => Get.find();

  Future<String?> createIssue({
    required String title,
    required String body,
    FeedbackCategory category = FeedbackCategory.issue,
    String? reporter,
    File? screenshot,
  }) async {
    final labels = category == FeedbackCategory.issue ? ['bug'] : ['ui'];
    final imageUrl = screenshot != null ? await _uploadImageToGitHub(screenshot) : '';

    final issueBody = _buildIssueBody(
      body: body,
      imageUrl: imageUrl,
      category: category,
      reporter: reporter,
    );

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
        'labels': labels,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['html_url'] as String?;
    }

    throw Exception('Failed to create issue: ${response.statusCode} ${response.body}');
  }

  String buildIssueBodyForTesting({
    required String body,
    required FeedbackCategory category,
    String? reporter,
    String? imageUrl,
  }) {
    return _buildIssueBody(
      body: body,
      category: category,
      reporter: reporter,
      imageUrl: imageUrl ?? '',
    );
  }

  Future<String> _uploadImageToGitHub(File imageFile) async {
    final base64Image = base64Encode(await imageFile.readAsBytes());
    final fileName = path.basename(imageFile.path);

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
        'branch': 'assets',
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['content']['download_url'] as String? ?? '';
    }
    return '';
  }

  String _buildIssueBody({
    required String body,
    required FeedbackCategory category,
    String? reporter,
    String imageUrl = '',
  }) {
    final buffer = StringBuffer(body);
    if (imageUrl.isNotEmpty) {
      buffer.write('\n\n<img src="$imageUrl" width=250/>');
    }
    if (reporter != null && reporter.trim().isNotEmpty) {
      buffer.write(
        '\n\n${category == FeedbackCategory.issue ? 'Issue' : 'Suggestion'} raised by ${reporter.trim()}.',
      );
    }
    return buffer.toString();
  }
}
