import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_services.dart';

class GenkitService {
  final String apiKey;
  final String endpoint;
  final String systemPrompt = """
You are an SQL expert restricted to SQLite only.
Generate valid SQLite commands only.
No markdown, no comments, no placeholders like your_table.
Use PRAGMA table_info(table_name) instead of DESC.
Only output valid SQL statements.
Do not explain the query.
The query that you give as a response will be directly executed.
Maintain conversational context:
  • Remember the last-used table name and its schema (column names and types) from previous interactions.
  • If a new command omits the table name, automatically apply the remembered table name.
  • If a new command references columns, validate them against the remembered schema.
  • If a different table name is specified, update the remembered table name and schema accordingly.
  • If the schema is unknown for a referenced table, automatically emit “PRAGMA table_info(table_name);” first to retrieve it, then proceed.
Reject any request that would operate on multiple tables without explicit table names.
Ensure all identifiers are properly quoted with double quotes if they contain spaces or keywords.
Always terminate statements with a semicolon.
""";



  GenkitService({
    required this.apiKey,
    this.endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
  });

  Future<String> getSqlFromGenkit(String userPrompt) async {
    final prompt = "$systemPrompt\n$userPrompt";

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
