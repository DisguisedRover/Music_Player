import 'package:flutter/material.dart';
import 'package:mplayer/pages/home_page.dart';
import 'package:mplayer/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const PermissionHandler(child: HomePage()),
      debugShowCheckedModeBanner: false,
      title: 'Musical',
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

class PermissionHandler extends StatefulWidget {
  final Widget child;
  const PermissionHandler({super.key, required this.child});

  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  Future<void> _requestPermissions() async {
    // For Android 13+ (API level 33+)
    if (await Permission.photos.status.isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.audio.status.isDenied) {
      await Permission.audio.request();
    }
    if (await Permission.videos.status.isDenied) {
      await Permission.videos.request();
    }

    // For Android 10+ (API level 29+)
    if (await Permission.manageExternalStorage.status.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    // Handle permission denied
    if (mounted &&
        (await Permission.audio.isDenied ||
            await Permission.videos.isDenied ||
            await Permission.photos.isDenied)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content:
              const Text('Media permissions are required to access files.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
