import 'dart:io';
import 'dart:math' as math;
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

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
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
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
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
      _animationController.repeat();
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
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _animationController.stop();
      } else {
        await _audioPlayer.resume();
        _animationController.repeat();
      }
      setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      _showSnackBar('Failed to toggle playback: $e');
      setState(
          () => _isPlaying = false); // Ensure the state reflects the failure.
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Now Playing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVisualizerBars(),
              _buildAlbumArtwork(),
              _buildSongTitle(),
              _buildSlider(),
              _buildControls(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizerBars() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          20,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 4,
            height: _isPlaying ? math.Random().nextDouble() * 40 : 3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArtwork() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 2 * math.pi,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'lib/images/icon4.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongTitle() {
    return Column(
      children: [
        Text(
          _currentFile.path.split('/').last.split('.').first,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Track ${_currentSongIndex + 1} of ${_playlist.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            thumbColor: Theme.of(context).colorScheme.primary,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _currentPosition.inSeconds.toDouble(),
            max: _totalDuration.inSeconds.toDouble(),
            onChanged: (value) {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            onPressed: _playPrevious,
            size: 32,
          ),
          const SizedBox(width: 20),
          _buildPlayPauseButton(),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            onPressed: _playNext,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _togglePlayPause,
        icon: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 40,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
