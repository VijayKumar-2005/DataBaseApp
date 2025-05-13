import 'package:flutter/material.dart';
import '../Services/database_services.dart';

class TableViewerPage extends StatefulWidget {
  final String tableName;
  final String apikey;

  const TableViewerPage({
    super.key,
    required this.tableName,
    required this.apikey,
  });

  @override
  State<TableViewerPage> createState() => _TableViewerPageState();
}

class _TableViewerPageState extends State<TableViewerPage> {
  List<Map<String, dynamic>> rows = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.rawQuery('SELECT * FROM "${widget.tableName}";');
      setState(() {
        rows = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading table: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Widget _buildTable() {
    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inbox, size: 64, color: Colors.white38),
            SizedBox(height: 12),
            Text("This table is empty.", style: TextStyle(color: Colors.white70, fontSize: 18)),
          ],
        ),
      );
    }

    final columnNames = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        margin: const EdgeInsets.all(12),
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.deepPurple.shade700),
            dataRowColor: WidgetStateProperty.all(const Color(0xFF2C2C2C)),
            horizontalMargin: 12,
            columnSpacing: 24,
            columns: columnNames.map((col) {
              return DataColumn(
                label: Text(
                  col,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
            rows: rows.map((row) {
              return DataRow(
                cells: columnNames.map((col) {
                  return DataCell(
                    Text(
                      '${row[col] ?? ''}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text('Table: ${widget.tableName}', style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
      )
          : error != null
          ? Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        child: _buildTable(),
      ),
    );
  }
}
