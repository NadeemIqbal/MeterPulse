import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/isar_service.dart';

/// Backs up and restores the Isar database (records only — photo files are not
/// included). Restore is applied on the next launch to avoid closing the live
/// database mid-session: the picked file is staged, and [IsarService.open]
/// swaps it into place before opening.
class BackupService {
  BackupService(this._isar);

  final Isar _isar;

  /// Copies the database to a temp file and opens the share sheet.
  Future<void> backup() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/meterpulse-backup.isar';
    final file = File(path);
    if (await file.exists()) await file.delete();

    await _isar.copyToFile(path);

    await Share.shareXFiles(
      [XFile(path)],
      subject: 'MeterPulse backup',
      text: 'MeterPulse database backup (readings & bills only — photos are '
          'not included).',
    );
  }

  /// Lets the user pick a backup file and stages it for restore. Returns true
  /// if a file was chosen; the caller must then prompt the user to restart.
  Future<bool> stageRestore() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final path = result?.files.single.path;
    if (path == null) return false;

    final dir = await getApplicationDocumentsDirectory();
    final staged = File('${dir.path}/${IsarService.pendingRestoreName}');
    if (await staged.exists()) await staged.delete();
    await File(path).copy(staged.path);
    return true;
  }
}
