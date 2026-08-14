import 'dart:io';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/download_progress.dart';

/// Servicio encubierto para la descarga de APKs y gestión de la instalación en Android/Plataformas soportadas.
class ApkDownloadService {
  final String methodChannelName;

  ApkDownloadService({
    this.methodChannelName = 'com.example.ficha_militancia/settings',
  });

  MethodChannel get _settingsChannel => MethodChannel(methodChannelName);

  /// Comprobar si la app cuenta con permiso para instalar paquetes en Android 8.0+ (REQUEST_INSTALL_PACKAGES).
  Future<bool> canInstallPackages() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? allowed =
          await _settingsChannel.invokeMethod<bool>('canRequestPackageInstalls');
      return allowed ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Abrir los ajustes del sistema de Android "Instalar aplicaciones desconocidas".
  Future<void> openInstallPermissionSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _settingsChannel.invokeMethod('openInstallPermissionSettings');
    } catch (_) {}
  }

  /// Realizar la descarga del archivo APK desde una URL destino.
  /// Si [allowSelfSignedCerts] es true, permite servidores con certificados SSL/TLS de desarrollo o autofirmados.
  Future<File> downloadApk({
    required String url,
    String fileName = "update.apk",
    void Function(DownloadProgress progress)? onProgress,
    bool allowSelfSignedCerts = true,
  }) async {
    final directory = await getTemporaryDirectory();
    final String filePath = "${directory.path}/$fileName";

    // Limpiar descargas anteriores si existen
    final oldFile = File(filePath);
    if (await oldFile.exists()) {
      await oldFile.delete();
    }

    final dio = Dio();

    if (allowSelfSignedCerts) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (onProgress != null) {
          final double progressRatio = total > 0 ? (received / total) : 0.0;
          final receivedMb = (received / (1024 * 1024)).toStringAsFixed(1);

          String statusMsg;
          if (total > 0) {
            final totalMb = (total / (1024 * 1024)).toStringAsFixed(1);
            statusMsg = "Descargando APK: $receivedMb MB de $totalMb MB";
          } else {
            statusMsg = "Descargando APK: $receivedMb MB...";
          }

          onProgress(
            DownloadProgress(
              receivedBytes: received,
              totalBytes: total,
              progress: progressRatio,
              statusMessage: statusMsg,
            ),
          );
        }
      },
    );

    return File(filePath);
  }

  /// Inicia el proceso de instalación de un APK descargado mediante OpenFile.
  Future<OpenResult> installApk(String filePath) async {
    return await OpenFile.open(
      filePath,
      type: "application/vnd.android.package-archive",
    );
  }

  /// En plataformas no-Android, abre la URL en un navegador externo.
  Future<bool> launchExternalDownloadUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
