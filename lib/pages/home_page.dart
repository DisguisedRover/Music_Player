import 'package:flutter/material.dart';
import 'music_list_screen.dart';
import '/components/my_button.dart';
import '/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _redirectIfNoMusic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MusicListScreen(),
      ),
    );
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
            Semantics(
              label: 'Button to browse music',
              child: MyButton(
                text: 'Browse Music',
                onTap: () => _redirectIfNoMusic(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
