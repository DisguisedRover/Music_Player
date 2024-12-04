import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mplayer/components/my_drawer.dart';
import '../services/file_service.dart';
import '../models/music_player_widget.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  _MusicListScreenState createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  List<File> _musicFiles = [];
  bool _isLoading = false;

  /// Fetch music files using file picker.
  Future<void> _fetchFilesFromPicker() async {
    setState(() => _isLoading = true);

    try {
      final files = await FileService.pickMusicFiles();
      setState(() {
        _musicFiles = files;
      });
    } catch (e) {
      debugPrint('Error fetching music files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching files: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch music files from a directory using file picker.
  Future<void> _fetchFilesFromDirectory() async {
    setState(() => _isLoading = true);

    try {
      final files = await FileService.pickMusicFromDirectory();
      setState(() {
        _musicFiles = files;
      });
    } catch (e) {
      debugPrint('Error fetching music files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching files: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(title: const Text('Music List')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _musicFiles.isEmpty
              ? _buildEmptyState()
              : _buildMusicList(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          onPressed: _fetchFilesFromDirectory,
          icon: const Icon(Icons.folder_open),
          label: const Text('Pick Directory'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No music files found. Use the buttons below to pick directories.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMusicList() {
    return ListView.builder(
      itemCount: _musicFiles.length,
      itemBuilder: (context, index) {
        final file = _musicFiles[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(file.path.split('/').last),
          trailing: const Icon(Icons.more_horiz_rounded),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerWidget(
                  playlist: _musicFiles,
                  currentIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
