import 'dart:io';

import 'package:flutter/material.dart';

class FileService {
  static const supportedExtensions = ['.mp3', '.wav', '.m4a', '.flac'];

  /// Scans the entire storage for music files.
  static Future<List<File>> scanEntireStorage() async {
    final List<File> musicFiles = [];
    final restrictedDirectories = [
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/obb',
    ];

    try {
      final storageRoot = _getStorageRootDirectory();
      if (storageRoot == null) {
        debugPrint('Error: Unable to determine storage root directory.');
        return musicFiles;
      }

      await for (var entity in storageRoot.list(recursive: true)) {
        try {
          if (entity is File &&
              supportedExtensions
                  .any((ext) => entity.path.toLowerCase().endsWith(ext))) {
            musicFiles.add(entity);
          } else if (entity is Directory) {
            // Skip restricted directories
            final dirPath = entity.path;
            if (restrictedDirectories.contains(dirPath) ||
                dirPath.split('/').last.startsWith('.')) {
              continue;
            }
          }
        } catch (e) {
          // Handle PathAccessException and log it
          debugPrint('Error accessing ${entity.path}: $e');
        }
      }

      debugPrint('Found ${musicFiles.length} music files across storage.');
    } catch (e) {
      debugPrint('Error scanning storage: $e');
    }

    return musicFiles;
  }

  /// Gets the root storage directory based on the platform.
  static Directory? _getStorageRootDirectory() {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0'); // Primary storage root
    } else if (Platform.isIOS) {
      // Limited to app sandboxed directories
      return Directory('/');
    }
    return null;
  }
}
