/*import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests storage or media permissions and handles different denial scenarios.
  static Future<bool> requestStoragePermission() async {
    PermissionStatus storageStatus = await Permission.storage.status;

    if (storageStatus.isGranted) {
      return true; // Permission granted
    }

    // Request permissions
    PermissionStatus result = await Permission.storage.request();
    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
*/
