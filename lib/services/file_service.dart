import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static const supportedExtensions = ['.mp3', '.wav', '.m4a', '.flac'];

  /// Scans the storage for music files with proper permissions
  static Future<List<File>> scanEntireStorage() async {
    final List<File> musicFiles = [];

    // Check and request permissions first
    if (!await _checkAndRequestPermissions()) {
      debugPrint('Required permissions not granted');
      return musicFiles;
    }

    try {
      final storageRoot = await _getStorageRootDirectory();
      if (storageRoot == null) {
        debugPrint('Error: Unable to determine storage root directory.');
        return musicFiles;
      }

      await _scanDirectory(storageRoot, musicFiles);
      debugPrint('Found ${musicFiles.length} music files across storage.');
    } catch (e) {
      debugPrint('Error scanning storage: $e');
    }

    return musicFiles;
  }

  /// Recursively scan directories while handling permissions
  static Future<void> _scanDirectory(
      Directory directory, List<File> musicFiles) async {
    try {
      await for (var entity in directory.list(recursive: false)) {
        if (entity is File) {
          if (supportedExtensions
              .any((ext) => entity.path.toLowerCase().endsWith(ext))) {
            musicFiles.add(entity);
          }
        } else if (entity is Directory) {
          // Skip system directories and hidden folders
          final dirName = entity.path.split('/').last;
          if (!dirName.startsWith('.') &&
              !entity.path.contains('/Android/data') &&
              !entity.path.contains('/Android/obb')) {
            await _scanDirectory(entity, musicFiles);
          }
        }
      }
    } on FileSystemException catch (e) {
      debugPrint('Access denied to ${directory.path}: $e');
    }
  }

  /// Check and request necessary permissions
  static Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13 and above
      if (await Permission.audio.request().isGranted &&
          await Permission.videos.request().isGranted &&
          await Permission.photos.request().isGranted) {
        return true;
      }

      // For Android 10 and below
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // For Android 11+, also check manage external storage
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  /// Gets the root storage directory based on the platform
  static Future<Directory?> _getStorageRootDirectory() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return Directory('/storage/emulated/0');
      } else {
        // Fall back to accessible directories
        final directories = await getExternalStorageDirectories();
        return directories?.first;
      }
    }
    return null;
  }
}
