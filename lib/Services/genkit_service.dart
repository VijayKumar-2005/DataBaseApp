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

  final String sqliteCheckPrompt = """
You are an expert in SQL queries focused exclusively on SQLite commands.
Your task is to analyze the user's query and respond with exactly one word:
- "true" if the query is related to SQLite commands involving inserting, deleting, adding, updating, altering, or viewing a table or its data.
- "false" if the query is unrelated to those SQLite actions.

Do not provide any explanation or additional text.
Only respond with "true" or "false".

User query: "{user_query}"
""";

  GenkitService({
    required this.apiKey,
    this.endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
  });

  Future<String> _sendPromptToGenkit(String prompt) async {
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
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) return text.toString().trim();
      throw Exception('No text found in Genkit response');
    } else {
      throw Exception("Failed to generate response: ${response.body}");
    }
  }

  Future<bool> isSqliteAction(String userQuery) async {
    final prompt = sqliteCheckPrompt.replaceAll("{user_query}", userQuery);
    final result = await _sendPromptToGenkit(prompt);
    return result.toLowerCase() == 'true';
  }

  Future<String> getSqlFromGenkit(String userQuery) async {
    final prompt = "$systemPrompt\n$userQuery";
    return await _sendPromptToGenkit(prompt);
  }

  Future<List<String>> processUserQuery(String userQuery) async {
    try {
      final isAction = await isSqliteAction(userQuery);
      if (!isAction) {
        return ['Error: Query not recognized as a valid SQLite action'];
      }
      final sql = await getSqlFromGenkit(userQuery);
      return await DatabaseService.instance.executeQuery(sql);
    } catch (e) {
      return ['Error: $e'];
    }
  }
}


