import 'package:databaseapp/Screens/sqlhomepage.dart';
import 'package:databaseapp/Services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Services/database_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.openBox();
  await DatabaseService.instance.initialize();
  await dotenv.load();
  String apiKey = dotenv.env['API_KEY'] ?? "API_KEY_NOT_FOUND";
  runApp(MyApp(apikey: apiKey));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apikey});
  final String apikey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQL Chatbot',
      debugShowCheckedModeBanner: false,
      home: SqlHomePage(apikey: apikey),
    );
  }
}
