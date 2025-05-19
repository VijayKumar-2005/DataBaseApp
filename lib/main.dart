import 'package:databaseapp/Screens/login_screen.dart';
import 'package:databaseapp/Services/firebase_authservice.dart';
import 'package:databaseapp/Services/hive_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'Services/database_services.dart';
import 'Services/message.dart';
import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<Message>('chatBox');
  await HiveService.openBox();
  await DatabaseService.instance.initialize();
  await dotenv.load();
  String apiKey = dotenv.env['API_KEY'] ?? "API_KEY_NOT_FOUND";
  runApp(MyApp(apikey: apiKey));
}
final auth = AuthService();
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apikey});
  final String apikey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQL Chatbot',
      debugShowCheckedModeBanner: false,
      home: LoginPage(apikey: apikey,),
    );
  }
}
