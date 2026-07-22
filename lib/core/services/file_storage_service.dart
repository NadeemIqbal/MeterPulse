import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Manages the on-disk image store under the app documents directory.
///
/// Reading/bill photos are copied here from the picker's temp location and
/// referenced by path in Isar (never stored as bytes).
class FileStorageService {
  FileStorageService();

  final Uuid _uuid = const Uuid();

  Future<Directory> _imagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies the file at [sourcePath] into permanent storage under a unique
  /// name, returning the new absolute path. Call this only when the user
  /// commits a reading/bill — not for a preview that might be discarded.
  Future<String> persistImage(String sourcePath) async {
    final dir = await _imagesDir();
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
    final dest = '${dir.path}/${_uuid.v4()}.$ext';
    await File(sourcePath).copy(dest);
    return dest;
  }

  /// Deletes a stored image if [path] is non-null and the file exists.
  Future<void> deleteImage(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
