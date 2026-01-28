import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/core/services/export_service.dart';
import 'package:loop_habit_tracker/core/services/import_service.dart';
import 'package:path_provider/path_provider.dart';

import 'package:loop_habit_tracker/core/themes/app_colors.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final ExportService _exportService = ExportService();
  final ImportService _importService = ImportService();
  List<File> _backupFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    setState(() {
      _isLoading = true;
    });
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where(
          (item) => item.path.endsWith('.csv') || item.path.endsWith('.db'),
        )
        .map((item) => File(item.path))
        .toList();

    // Sort files by modification date
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      _backupFiles = files;
      _isLoading = false;
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      final path = await _exportService.exportToCSV();
      _showSnackbar('Exported to CSV successfully at $path');
      _loadBackupFiles();
    } catch (e) {
      _showSnackbar('Error exporting to CSV: $e', isError: true);
    }
  }

  Future<void> _exportToSQLite() async {
    try {
      final path = await _exportService.exportToSQLite();
      _showSnackbar('Exported to SQLite successfully at $path');
      _loadBackupFiles();
    } catch (e) {
      _showSnackbar('Error exporting to SQLite: $e', isError: true);
    }
  }

  Future<void> _importFromCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        try {
          await _importService.importFromCSV(
            filePath,
            strategy: ImportStrategy.replace,
          );
          _showSnackbar('Import from CSV successful.');
        } catch (e) {
          _showSnackbar('Error importing from CSV: $e', isError: true);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  Future<void> _importFromSQLite() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );
    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        try {
          await _importService.importFromSQLite(filePath);
          _showSnackbar('Import from SQLite successful.');
        } catch (e) {
          _showSnackbar('Error importing from SQLite: $e', isError: true);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Export Data', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _exportToCSV,
              child: const Text('Export to CSV'),
            ),
            ElevatedButton(
              onPressed: _exportToSQLite,
              child: const Text('Export to SQLite'),
            ),
            const SizedBox(height: 24),
            Text('Import Data', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _importFromCSV,
              child: const Text('Import from CSV'),
            ),
            ElevatedButton(
              onPressed: _importFromSQLite,
              child: const Text('Import from SQLite'),
            ),
            const SizedBox(height: 24),
            Text(
              'Backup History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _backupFiles.isEmpty
                ? const Center(child: Text('No backup files found.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _backupFiles.length,
                    itemBuilder: (context, index) {
                      final file = _backupFiles[index];
                      final fileName = file.path.split('/').last;
                      final modifiedDate = file.lastModifiedSync();
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            fileName.endsWith('.csv')
                                ? Icons.description
                                : Icons.storage,
                            color: AppColors.accent,
                          ),
                          title: Text(fileName),
                          subtitle: Text(modifiedDate.toLocal().toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await file.delete();
                              _loadBackupFiles();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
