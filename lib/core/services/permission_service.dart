import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around `permission_handler`.
///
/// Wrapping the package lets feature code depend on this interface only and
/// gives us a single seam to mock in tests.
abstract class PermissionService {
  Future<bool> requestCamera();
  Future<bool> requestGallery();
}

class PermissionServiceImpl implements PermissionService {
  const PermissionServiceImpl();

  @override
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted || status.isLimited;
  }

  @override
  Future<bool> requestGallery() async {
    // On Android 13+ the gallery permission is `photos`; older versions
    // expose `storage`. We try the modern one first and fall back.
    final modern = await Permission.photos.request();
    if (modern.isGranted || modern.isLimited) return true;

    final legacy = await Permission.storage.request();
    return legacy.isGranted || legacy.isLimited;
  }
}
