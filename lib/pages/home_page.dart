import 'package:flutter/material.dart';
import 'music_list_screen.dart';
import '/components/my_button.dart';
import '/components/my_drawer.dart';
import '/services/file_service.dart'; // Import the FileService

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  Future<void> _handleMusicBrowse(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final musicFiles = await FileService.scanEntireStorage();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicListScreen(initialFiles: musicFiles),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error accessing music files. Please check permissions.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text(
          'Musical',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 30),
            Text(
              'Welcome to Musical',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Semantics(
                label: 'Button to browse music',
                child: MyButton(
                  text: 'Browse Music',
                  onTap: () => _handleMusicBrowse(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
