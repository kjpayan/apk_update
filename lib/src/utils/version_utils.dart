import 'package:package_info_plus/package_info_plus.dart';

/// Utilidades estáticas para la inspección y comparación de versiones de aplicaciones.
class VersionUtils {
  /// Obtiene la versión actual instalada de la app (ej: "1.0.0+1" o "1.0.0").
  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;
      return buildNumber.isNotEmpty ? "$version+$buildNumber" : version;
    } catch (_) {
      return "1.0.0+1";
    }
  }

  /// Compara si la versión instalada ([current]) es menor a la versión disponible ([latest]).
  /// Soporta el formato estándar semver (`1.2.3`) y build numbers (`1.2.3+4`).
  static bool isVersionOutdated(String current, String latest) {
    try {
      final cleanCurrent = current.split('+')[0];
      final cleanLatest = latest.split('+')[0];

      final currentParts = cleanCurrent.split('.').map(int.parse).toList();
      final latestParts = cleanLatest.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length; i++) {
        final currentVal = i < currentParts.length ? currentParts[i] : 0;
        if (latestParts[i] > currentVal) return true;
        if (latestParts[i] < currentVal) return false;
      }
    } catch (_) {}
    return false;
  }
}
