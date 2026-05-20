import 'package:permission_handler/permission_handler.dart';

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
    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return true;

    final storage = await Permission.storage.request();
    return storage.isGranted || storage.isLimited;
  }
}
