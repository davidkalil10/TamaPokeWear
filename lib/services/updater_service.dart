import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter/foundation.dart';

class UpdaterService {
  static const String repoOwner = 'davidkalil10';
  static const String repoName = 'TamaPokeWear';
  static const String releaseApiUrl = 'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  /// Retorna a URL de download se houver uma nova versão, caso contrário, null.
  static Future<String?> checkForUpdate() async {
    try {
      final dio = Dio();
      final response = await dio.get(releaseApiUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        final tagName = data['tag_name'] as String;
        // Exemplo: "v1.0.7"
        final latestVersion = tagName.replaceAll('v', '').replaceAll('V', '');

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        
        debugPrint('Current Version: $currentVersion');
        debugPrint('Latest Version on GitHub: $latestVersion');

        if (_isVersionGreater(latestVersion, currentVersion)) {
          final assets = data['assets'] as List;
          for (var asset in assets) {
            final name = asset['name'] as String;
            if (name.endsWith('.apk')) {
              return asset['browser_download_url'] as String;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  static bool _isVersionGreater(String latest, String current) {
    try {
      // Ex: "1.0.7" -> [1, 0, 7]
      final vLatest = latest.split('.').map(int.parse).toList();
      final vCurrent = current.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final l = i < vLatest.length ? vLatest[i] : 0;
        final c = i < vCurrent.length ? vCurrent[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Inicia o download e dispara a instalação
  static Stream<OtaEvent> downloadAndInstall(String url) {
    return OtaUpdate().execute(
      url,
      destinationFilename: 'tamapokewear_update.apk',
    );
  }
}
