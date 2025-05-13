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
      return const Center(child: Text("This table is empty."));
    }

    final columnNames = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columnNames
            .map((col) => DataColumn(label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold))))
            .toList(),
        rows: rows
            .map((row) => DataRow(
          cells: columnNames
              .map((col) => DataCell(Text('${row[col] ?? ''}')))
              .toList(),
        ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table: ${widget.tableName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildTable(),
      ),
    );
  }
}
