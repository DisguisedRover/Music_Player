import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  static const supportedExtensions = ['.mp3', '.wav', '.m4a', '.flac'];

  /// Opens the file picker to select music files.
  static Future<List<File>> pickMusicFiles() async {
    try {
      // Use file_picker to allow the user to select files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            supportedExtensions.map((e) => e.replaceFirst('.', '')).toList(),
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.map((f) => File(f.path!)).toList();
      }
    } catch (e) {
      debugPrint('Error picking music files: $e');
    }
    return [];
  }

  /// Opens the file picker to select a directory and fetch music files from it.
  static Future<List<File>> pickMusicFromDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        final directory = Directory(result);
        return await _fetchFiles(directory);
      }
    } catch (e) {
      debugPrint('Error picking directory: $e');
    }
    return [];
  }

  /// Fetches music files from a directory.
  static Future<List<File>> _fetchFiles(Directory directory) async {
    final List<File> musicFiles = [];
    try {
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File &&
            supportedExtensions
                .any((ext) => entity.path.toLowerCase().endsWith(ext))) {
          musicFiles.add(entity);
        }
      }
      debugPrint('Found ${musicFiles.length} music files in ${directory.path}');
    } catch (e) {
      debugPrint('Error scanning directory: $e');
    }
    return musicFiles;
  }
}
