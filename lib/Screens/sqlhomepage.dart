import 'package:databaseapp/Screens/chatscreen.dart';
import 'package:databaseapp/Screens/console.dart';
import 'package:databaseapp/Screens/view_tables.dart';
import 'package:flutter/material.dart';

class SqlHomePage extends StatelessWidget {
  final String apikey;
  const SqlHomePage({super.key, required this.apikey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(
          children: const [
            DrawerHeader(
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
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        title: const Text('SQL Tools', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            _OptionTile(
              icon: Icons.chat_bubble_outline,
              title: 'SQL Chatbot',
              subtitle: 'Talk to a smart SQLite assistant',
              destination: ChatScreen(apikey: apikey),
            ),
            _OptionTile(
              icon: Icons.terminal,
              title: 'SQL Console',
              subtitle: 'Run raw SQL queries directly',
              destination: QueryScreen(),
            ),
            _OptionTile(
              icon: Icons.table_chart_outlined,
              title: 'View Tables',
              subtitle: 'Browse and inspect database tables',
              destination: ViewTablesPage(apikey: apikey),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.shade700.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Icon(icon, color: Colors.deepPurpleAccent, size: 32),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }
}
