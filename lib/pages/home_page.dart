import 'package:flutter/material.dart';
import '/models/music_list_screen.dart';
import '/components/my_button.dart';
import '/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(title: const Text('Musical')),
      body: Center(
        child: MyButton(
          text: 'Browse',
          onTap: () {
            // Navigate to the MusicListScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MusicListScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
