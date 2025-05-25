import 'package:flutter/material.dart';
import '../Services/database_services.dart';
import 'table_viewer_page.dart';
class ViewTablesPage extends StatefulWidget {
  const ViewTablesPage({super.key});
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
    final allNames = names
        .expand((name) => name.split('\n'))
        .where((name) => name.isNotEmpty && !name.startsWith('No tables'))
        .toList();
    setState(() {
      tableNames = allNames;
      isLoading = false;
    });
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
                    trailing: IconButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Delete "$tableName"?',style: TextStyle(color: Colors.white),),
                            backgroundColor: Colors.grey.shade900,
                            content: Text('Are you sure you want to permanently delete this table?',style: TextStyle(color: Colors.white),),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel',style: TextStyle(color: Colors.white),),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete',style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await DatabaseService.instance.deleteTable(tableName);
                          setState(() {
                            tableNames.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text('Table "$tableName" deleted')),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(
                                seconds: 2
                              ),
                            ),
                          );
                        }
                      },

                      icon: const Icon(
                        Icons.delete,
                        size: 27,
                        color: Colors.red,
                      ),
                    ),
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
