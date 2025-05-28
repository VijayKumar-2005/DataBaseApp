import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class ImportDatabasePage extends StatefulWidget {
  const ImportDatabasePage({super.key});
  @override
  State<ImportDatabasePage> createState() => _ImportDatabasePageState();
}
class _ImportDatabasePageState extends State<ImportDatabasePage> {
  String? _statusMessage;
  Future<void> _importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        final pickedPath = result.files.single.path!;
        final fileName = basename(pickedPath);
        final extension = fileName.split('.').last.toLowerCase();

        if (extension != 'db' && extension != 'sqlite') {
          setState(() {
            _statusMessage = "❗Selected file is not a database file (.db/.sqlite).";
          });
          return;
        }
        final pickedFile = File(pickedPath);
        final destinationPath = await getDatabaseLocation(fileName);
        await pickedFile.copy(destinationPath);
        setState(() {
          _statusMessage = "✅ Imported as: $fileName\nSaved to:\n$destinationPath";
        });
      } else {
        setState(() {
          _statusMessage = "❗No file selected.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error importing database:\n$e";
      });
    }
  }
  Future<String> getDatabaseLocation(String dbName) async {
    final directory = await getDatabasesPath();
    return '$directory/$dbName';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Import Database"),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: const Text("Select Database File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _importDatabase,
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}