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

  // Function to request storage permissions
  Future<void> _requestStoragePermissions(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isDenied) {
        // Show a dialog explaining why the permission is needed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content:
                const Text('Storage permission is required to access files.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () => openAppSettings(), // Open app settings
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }

    // Optional: Request manage external storage permission if needed
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Request permissions when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestStoragePermissions(context);
    });

    return MaterialApp(
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      title: 'Musical',
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
