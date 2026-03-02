import 'package:loop_habit_tracker/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/core/services/export_service.dart';
import 'package:loop_habit_tracker/core/services/import_service.dart';
import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/habit_update_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final ExportService _exportService = ExportService();
  final ImportService _importService = ImportService();

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
      if (path.contains('Download')) {
        _showSnackbar(
          AppLocalizations.of(context)!.savedToDownloads(path.split('/').last),
        );
      } else {
        _showSnackbar(AppLocalizations.of(context)!.exportSuccessSharing);
      }
      // Share regardless, as it's convenient
      await Share.shareXFiles([
        XFile(path),
      ], text: AppLocalizations.of(context)!.shareExportCSV);
    } catch (e) {
      _showSnackbar(
        AppLocalizations.of(context)!.errorExportingCSV(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _exportToSQLite() async {
    try {
      final path = await _exportService.exportToSQLite();
      if (path.contains('Download')) {
        _showSnackbar(
          AppLocalizations.of(context)!.savedToDownloads(path.split('/').last),
        );
      } else {
        _showSnackbar(AppLocalizations.of(context)!.exportSuccessSharing);
      }
      await Share.shareXFiles([
        XFile(path),
      ], text: AppLocalizations.of(context)!.shareBackupSQLite);
    } catch (e) {
      _showSnackbar(
        AppLocalizations.of(context)!.errorExportingSQLite(e.toString()),
        isError: true,
      );
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
          final message = await _importService.importFromCSV(
            filePath,
            strategy: ImportStrategy.replace,
          );
          _showSnackbar(message);
          // Trigger global update
          if (mounted) {
            context.read<HabitUpdateProvider>().notifyUpdated();
          }
        } catch (e) {
          _showSnackbar(
            AppLocalizations.of(context)!.errorImportingCSV(e.toString()),
            isError: true,
          );
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
          _showSnackbar(AppLocalizations.of(context)!.importSuccess);
          // Trigger global update
          if (mounted) {
            context.read<HabitUpdateProvider>().notifyUpdated();
          }
        } catch (e) {
          _showSnackbar(
            AppLocalizations.of(context)!.errorImportingSQLite(e.toString()),
            isError: true,
          );
        }
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.backupAndRestore),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.exportData,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _exportToCSV,
              icon: const Icon(Icons.file_download),
              label: Text(AppLocalizations.of(context)!.exportToCSV),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _exportToSQLite,
              icon: const Icon(Icons.dataset),
              label: Text(AppLocalizations.of(context)!.exportToSQLite),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.importData,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _importFromCSV,
              icon: const Icon(Icons.file_upload),
              label: Text(AppLocalizations.of(context)!.importFromCSV),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _importFromSQLite,
              icon: const Icon(Icons.settings_backup_restore),
              label: Text(AppLocalizations.of(context)!.importFromSQLite),
            ),
          ],
        ),
      ),
    );
  }
}
