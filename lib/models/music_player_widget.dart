// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerWidget extends StatefulWidget {
  final List<File> playlist;
  final int currentIndex;

  const MusicPlayerWidget(
      {super.key, required this.playlist, required this.currentIndex});

  @override
  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  late final AudioPlayer _audioPlayer = AudioPlayer();
  late File _currentFile;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  late List<File> _playlist;
  late int _currentSongIndex;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
    _currentSongIndex = widget.currentIndex;
    _currentFile = _playlist[_currentSongIndex];
    _initializePlayer();
  }

  void _initializePlayer() {
    _playMusic();
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _totalDuration = duration);
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) => _playNext());
  }

  Future<void> _playMusic() async {
    try {
      await _audioPlayer.play(DeviceFileSource(_currentFile.path));
      setState(() => _isPlaying = true);
    } catch (e) {
      _showSnackBar('Error playing music: $e');
    }
  }

  Future<void> _playNext() async {
    if (_currentSongIndex < _playlist.length - 1) {
      _currentSongIndex++;
      _updateCurrentFileAndPlay();
    }
  }

  Future<void> _playPrevious() async {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
      _updateCurrentFileAndPlay();
    }
  }

  void _updateCurrentFileAndPlay() {
    setState(() {
      _currentFile = _playlist[_currentSongIndex];
    });
    _playMusic();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAlbumArtwork(),
            const SizedBox(height: 20),
            _buildSongTitle(),
            const SizedBox(height: 20),
            _buildSlider(),
            const SizedBox(height: 20),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArtwork() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('lib/images/icon4.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSongTitle() {
    return Text(
      _currentFile.path.split('/').last,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        Slider(
          value: _currentPosition.inSeconds.toDouble(),
          max: _totalDuration.inSeconds.toDouble(),
          onChanged: (value) {
            _audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formatDuration(_currentPosition)),
            const SizedBox(width: 10),
            const Text('/'),
            const SizedBox(width: 10),
            Text(_formatDuration(_totalDuration)),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _playPrevious,
          icon: const Icon(Icons.skip_previous),
        ),
        IconButton(
          onPressed: _togglePlayPause,
          icon: Icon(
            _isPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.play_arrow_rounded,
          ),
        ),
        IconButton(
          onPressed: _playNext,
          icon: const Icon(Icons.skip_next),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
