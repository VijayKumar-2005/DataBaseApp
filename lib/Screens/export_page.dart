import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:databaseapp/Screens/table_viewer_page.dart';
import '../Services/database_services.dart';

class DatabaseInfoPage extends StatefulWidget {
  const DatabaseInfoPage({super.key});

  @override
  State<DatabaseInfoPage> createState() => _DatabaseInfoPageState();
}

class _DatabaseInfoPageState extends State<DatabaseInfoPage> {
  List<String> _tables = [];
  final String _dbPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    final names = await DatabaseService.instance.executeQuery("tables");
    final allNames = names
        .expand((name) => name.split('\n'))
        .where((name) => name.isNotEmpty && !name.startsWith('No tables'))
        .toList();
    setState(() {
      _tables = allNames;
      _isLoading = false;
    });
  }

  Future<void> _exportDatabase(BuildContext context) async {
    final file = File(_dbPath);
    if (await file.exists()) {
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(_dbPath)], text: "Database Export"
          )
        );
      } catch (e) {
        _showSnackBar("Error sharing database: $e",context);
      }
    } else {
      _showSnackBar("Database file not found at $_dbPath",context);
    }
  }

  Future<void> _copyDatabaseToExternalStorage(BuildContext context) async {
    final file = File(_dbPath);
    if (await file.exists()) {
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final newPath = join(extDir.path, basename(_dbPath));
          await file.copy(newPath);
          _showSnackBar("Database copied to: $newPath",context);
        } else {
          _showSnackBar("External storage not available",context);
        }
      } catch (e) {
        _showSnackBar("Error copying database: $e",context);
      }
    } else {
      _showSnackBar("Database file not found to copy",context);
    }
  }

  void _showSnackBar(String message,BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Database Explorer'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _tables.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildTableCard(_tables[index],context);

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Export Database',
                  color: const Color(0xFF6A1B9A),
                  onPressed: ()=>_exportDatabase(context),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.save_alt,
                  label: 'Save to External Storage',
                  color: const Color(0xFF00897B),
                  onPressed: ()=>_copyDatabaseToExternalStorage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(String tableName,BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color(0xFF1E1E1E),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TableViewerPage(tableName: tableName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.table_chart, color: Colors.deepPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tableName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view contents',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: color.withValues(alpha: 0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }
}