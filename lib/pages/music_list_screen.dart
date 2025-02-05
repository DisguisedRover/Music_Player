import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mplayer/components/my_drawer.dart';
import '../services/file_service.dart';
import 'music_player_widget.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({
    super.key,
    required this.initialFiles,
  });

  final List<File> initialFiles;

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  bool _isLoading = false;
  late List<File> _musicFiles;

  @override
  void initState() {
    super.initState();
    _musicFiles = widget.initialFiles;
    if (_musicFiles.isEmpty) {
      _autoDiscoverMusic(); // Only scan if no initial files
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(
          'Found ${_musicFiles.length} music files!',
          Colors.green,
        );
      });
    }
  }

  Future<void> _autoDiscoverMusic() async {
    if (_isLoading) return; // Prevent multiple scans

    setState(() => _isLoading = true);

    try {
      final files = await FileService.scanEntireStorage();

      if (mounted) {
        setState(() {
          _musicFiles = files;
        });

        if (files.isNotEmpty) {
          _showSnackBar(
            'Found ${files.length} music files!',
            Colors.green,
          );
        } else {
          _showSnackBar(
            'No music files found in storage.',
            Colors.orange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error discovering music files. Please check permissions.',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please add music files to your storage or check app permissions.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _autoDiscoverMusic,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isLoading ? 'Scanning...' : 'Rescan Storage'),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicList() {
    return ListView.builder(
      itemCount: _musicFiles.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final file = _musicFiles[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.music_note,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            file.path.split('/').last,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            Directory(file.path).parent.path,
            style: Theme.of(context).textTheme.bodySmall,
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
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _autoDiscoverMusic,
            tooltip: 'Rescan Music',
          ),
        ],
      ),
      body: _musicFiles.isEmpty ? _buildEmptyState() : _buildMusicList(),
    );
  }
}
