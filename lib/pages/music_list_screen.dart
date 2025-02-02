import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mplayer/components/my_drawer.dart';
import '../services/file_service.dart';
import 'music_player_widget.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  _MusicListScreenState createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  List<File> _musicFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _autoDiscoverMusic(); // Automatically scan for music files
  }

  Future<void> _autoDiscoverMusic() async {
    setState(() => _isLoading = true);

    try {
      // Automatically scan entire storage for music files
      final files = await FileService.scanEntireStorage();

      setState(() {
        _musicFiles = files;
      });

      if (files.isNotEmpty) {
        _showSnackBar(
            'Found ${files.length} music files automatically!', Colors.green);
      } else {
        _showSnackBar('No music files found in storage.', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error discovering music files: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off_rounded,
            size: 100,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'No music files found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Please add music files to your storage.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _autoDiscoverMusic,
            icon: const Icon(Icons.refresh),
            label: const Text('Rescan Storage'),
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
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.music_note),
          ),
          title: Text(
            file.path.split('/').last, // Display the file name
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text(
          'Music List',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _autoDiscoverMusic,
            tooltip: 'Rescan Music',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : _musicFiles.isEmpty
              ? _buildEmptyState() // Show empty state if no music is found
              : _buildMusicList(), // Display the list of music files
    );
  }
}
