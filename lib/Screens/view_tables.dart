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
      tableNames = names
          .where((name) => name.isNotEmpty && !name.startsWith('No tables') && name != 'android_metadata' && name != 'emp')
          .toList();
      isLoading = false;
    });

    print(tableNames.length);
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text("Available Tables", style: TextStyle(color: Colors.white)),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
          ),
        )
            : tableNames.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.table_chart_outlined, size: 64, color: Colors.white54),
              SizedBox(height: 12),
              Text(
                "No tables found.",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: tableNames.length,
          itemBuilder: (context, index) {
            final tableName = tableNames[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
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
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade700.withValues(alpha: 0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: Text(
                      tableName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepPurpleAccent),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
