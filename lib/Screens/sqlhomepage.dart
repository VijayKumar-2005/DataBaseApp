import 'package:databaseapp/Screens/chatscreen.dart';
import 'package:databaseapp/Screens/console.dart';
import 'package:databaseapp/Screens/settings_page.dart';
import 'package:databaseapp/Screens/view_tables.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'export_page.dart';

class SqlHomePage extends StatelessWidget {
  final String apikey;
  const SqlHomePage({super.key, required this.apikey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
              ),
              child: Center(
                child: Text(
                  'SQL Tools Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatabaseInfoPage()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.import_export, color: Colors.white),
                title: Text('Export database', style: TextStyle(color: Colors.white)),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text('Settings', style: TextStyle(color: Colors.white)),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    title: Text('Confirm',style: TextStyle(color: Colors.white),),
                    content: Text('Are you sure you want to clear all chat history?',style: TextStyle(color: Colors.white),),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Clear')),
                    ],
                  ),
                );

                if (confirm == true) {
                  final box = await Hive.openBox('chatBox');
                  await box.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chat history cleared')),
                  );
                }
              },
              child: ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
                title: Text('Clear Chat History', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('SQL Tools', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF121212),
        child: ListView(
          children: [
            _SimpleTile(
              icon: Icons.chat_bubble_outline,
              title: 'SQL Chatbot',
              subtitle: 'Talk to a smart SQLite assistant',
              destination: ChatScreen(apikey: apikey),
            ),
            _SimpleTile(
              icon: Icons.terminal,
              title: 'SQL Console',
              subtitle: 'Run raw SQL queries directly',
              destination: QueryScreen(),
            ),
            _SimpleTile(
              icon: Icons.table_chart_outlined,
              title: 'View Tables',
              subtitle: 'Browse and inspect database tables',
              destination: ViewTablesPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
    );
  }
}
