import 'package:flutter/material.dart';
import '../Services/database_services.dart';
import 'table_viewer_page.dart';

class ViewTablesPage extends StatefulWidget {
  final String apikey;
  const ViewTablesPage({super.key, required this.apikey});

  @override
  State<ViewTablesPage> createState() => _ViewTablesPageState();
}

class _ViewTablesPageState extends State<ViewTablesPage> {
  List<String> tableNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    final names = await DatabaseService.instance.executeQuery("tables");
    setState(() {
      tableNames = names.where((name) => !name.startsWith('No tables')).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Tables")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tableNames.isEmpty
          ? const Center(child: Text("No tables found."))
          : ListView.builder(
        itemCount: tableNames.length,
        itemBuilder: (context, index) {
          final tableName = tableNames[index];
          return Card(
            child: ListTile(
              title: Text(tableName),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TableViewerPage(
                      tableName: tableName,
                      apikey: widget.apikey,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
