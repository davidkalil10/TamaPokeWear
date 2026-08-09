import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class BackupService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint("Error signing in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
  
  Future<void> signInSilently() async {
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint("Error silent sign in: $e");
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    return drive.DriveApi(authenticateClient);
  }

  Future<bool> backupData() async {
    final api = await _getDriveApi();
    if (api == null) return false;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tamapoke.hive');
      if (!await file.exists()) return false;

      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'tamapoke.hive'",
      );

      final media = drive.Media(file.openRead(), await file.length());
      
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final driveFileId = fileList.files!.first.id!;
        await api.files.update(
          drive.File(),
          driveFileId,
          uploadMedia: media,
        );
      } else {
        final driveFile = drive.File()
          ..name = 'tamapoke.hive'
          ..parents = ['appDataFolder'];
        await api.files.create(
          driveFile,
          uploadMedia: media,
        );
      }
      return true;
    } catch (e) {
      debugPrint("Backup error: $e");
      return false;
    }
  }

  Future<bool> restoreData() async {
    final api = await _getDriveApi();
    if (api == null) return false;

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'tamapoke.hive'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return false;
      }

      final driveFileId = fileList.files!.first.id!;
      
      final response = await api.files.get(driveFileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/tamapoke.hive');
      
      final sink = localFile.openWrite();
      await response.stream.pipe(sink);
      await sink.close();
      
      return true;
    } catch (e) {
      debugPrint("Restore error: $e");
      return false;
    }
  }
  
  Future<bool> deleteBackup() async {
    final api = await _getDriveApi();
    if (api == null) return false;

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'tamapoke.hive'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        await api.files.delete(fileList.files!.first.id!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Delete backup error: $e");
      return false;
    }
  }
  
  Future<DateTime?> getBackupDate() async {
    final api = await _getDriveApi();
    if (api == null) return null;

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'tamapoke.hive'",
        $fields: "files(id, modifiedTime)",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.modifiedTime?.toLocal();
      }
      return null;
    } catch (e) {
      debugPrint("Get backup date error: $e");
      return null;
    }
  }
}
