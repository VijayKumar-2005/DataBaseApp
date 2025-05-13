import 'package:databaseapp/Screens/chatscreen.dart';
import 'package:databaseapp/Screens/console.dart';
import 'package:databaseapp/Screens/view_tables.dart';
import 'package:flutter/material.dart';

class SqlHomePage extends StatelessWidget {
  const SqlHomePage({super.key, required this.apikey});
  final String apikey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        title: const Text('SQL Tools',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child: ListView(
          children: [
            Container(height: 24,),
            _OptionTile(
              icon: Icons.chat,
              title: 'SQL Chatbot',
              destination: ChatScreen(apikey: apikey),
            ),
            Container(height: 12,),
            _OptionTile(
              icon: Icons.code,
              title: 'SQL Console',
              destination: QueryScreen(),
            ),
            Container(height: 12,),
            _OptionTile(
              icon: Icons.table_chart,
              title: 'View Tables',
              destination: ViewTablesPage(apikey: apikey),
            ),
            Container(height: 12,),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget destination;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        tileColor: Colors.grey.shade800,
        leading: Icon(icon,color: Colors.deepPurple.shade400,),
        title: Text(title,style: TextStyle(color:Colors.deepPurple.shade400),),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16,color: Colors.deepPurpleAccent,),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
      ),
    );
  }
}