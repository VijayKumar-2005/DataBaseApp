import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:databaseapp/Screens/chatscreen.dart';
import 'package:databaseapp/Screens/console.dart';
import 'package:databaseapp/Screens/login_screen.dart';
import 'package:databaseapp/Screens/settings_page.dart';
import 'package:databaseapp/Screens/view_tables.dart';
import 'package:databaseapp/Services/firebase_authservice.dart';
import 'package:flutter/material.dart';

import 'export_page.dart';

final AuthService auth = AuthService();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SqlHomePage extends StatefulWidget {
  final String apikey;
  const SqlHomePage({super.key, required this.apikey});

  @override
  _SqlHomePageState createState() => _SqlHomePageState();
}

class _SqlHomePageState extends State<SqlHomePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDoc;

  @override
  void initState() {
    super.initState();
    final uid = auth.getCurrentUser()?.uid;
    if (uid != null) {
      _userDoc = _firestore.collection('users').doc(uid).get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('SQL Tools', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFE040FB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1D1D1D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          children: [
            _FeatureCard(
              icon: Icons.chat_bubble_outline,
              title: 'SQL Chatbot',
              subtitle: 'Talk to a smart SQLite assistant',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(apikey: widget.apikey)),
              ),
            ),
            _FeatureCard(
              icon: Icons.terminal,
              title: 'SQL Console',
              subtitle: 'Run raw SQL queries directly',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QueryScreen()),
              ),
            ),
            _FeatureCard(
              icon: Icons.table_chart_outlined,
              title: 'View Tables',
              subtitle: 'Browse and inspect database tables',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewTablesPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _userDoc,
              builder: (context, snapshot) {
                String displayName = 'Guest User';
                String email = '';
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  displayName = data?['name'] ?? auth.getCurrentUser()?.email?.split('@').first ?? 'Guest User';
                  email = auth.getCurrentUser()?.email ?? '';
                } else if (auth.getCurrentUser() != null) {
                  email = auth.getCurrentUser()!.email ?? '';
                }
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFE040FB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _DrawerItem(
              icon: Icons.import_export,
              label: 'Export Database',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatabaseInfoPage()),
              ),
            ),
            _DrawerItem(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            const Spacer(),
            _DrawerItem(
              icon: Icons.logout,
              iconColor: Colors.redAccent,
              label: 'Log Out',
              labelColor: Colors.redAccent,
              onTap: () async {
                await auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage(apikey: widget.apikey)),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade800,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepPurpleAccent,
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: labelColor)),
      onTap: onTap,
    );
  }
}
