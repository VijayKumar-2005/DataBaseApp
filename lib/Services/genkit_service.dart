import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_services.dart';

class GenkitService {
  final String apiKey;
  final String endpoint;
  final String globalInstruction =
      "Respond with raw SQL code only, no markdown or extra formatting.";

  GenkitService({
    required this.apiKey,
    this.endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
  });

  Future<String> getSqlFromGenkit(String userPrompt) async {
    final prompt = "$globalInstruction $userPrompt";

    final response = await http.post(
      Uri.parse("$endpoint?key=$apiKey"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      return text.toString().trim();
    } else {
      throw Exception("Failed to generate SQL: ${response.body}");
    }
  }

  Future<List<String>> runGenkitSql(String userPrompt) async {
    try {
      final sql = await getSqlFromGenkit(userPrompt);
      return await DatabaseService.instance.executeQuery(sql);
    } catch (e) {
      return ['Error: $e'];
    }
  }
}
