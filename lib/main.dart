import 'package:databaseapp/Screens/chatscreen.dart';
import 'package:databaseapp/Screens/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  String apiKey = dotenv.env['API_KEY'] ?? "API_KEY_NOT_FOUND";
  runApp(MyApp(apikey: apiKey,));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key,required this.apikey});
  final String apikey;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: ChatScreen(apikey: apikey,),
    );
  }
}
