library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'src/models/download_progress.dart';
import 'src/services/apk_download_service.dart';
import 'src/ui/apk_download_dialog.dart';
import 'src/utils/version_utils.dart';

export 'src/models/download_progress.dart';
export 'src/services/apk_download_service.dart';
export 'src/ui/apk_download_dialog.dart';
export 'src/utils/version_utils.dart';

/// Controlador principal de alto nivel para gestionar las descargas de actualización de APK.
class ApkUpdater {
  final ApkDownloadService _downloadService;

  ApkUpdater({ApkDownloadService? downloadService})
      : _downloadService = downloadService ?? ApkDownloadService();

  /// Comprueba si la versión instalada está desactualizada con respecto a la última versión.
  static bool isVersionOutdated(String currentVersion, String latestVersion) {
    return VersionUtils.isVersionOutdated(currentVersion, latestVersion);
  }

  /// Obtiene la versión actual instalada según la plataforma.
  static Future<String> getAppVersion() {
    return VersionUtils.getAppVersion();
  }

  /// Comprobar si se tienen permisos para instalar paquetes en Android.
  Future<bool> canInstallPackages() {
    return _downloadService.canInstallPackages();
  }

  /// Abrir ajustes de instalación en Android.
  Future<void> openInstallSettings() {
    return _downloadService.openInstallPermissionSettings();
  }

  /// Descarga el APK e inicia la instalación. Muestra un diálogo de progreso integrado si se proporciona un [context].
  Future<OpenResult?> downloadAndInstall({
    required String downloadUrl,
    BuildContext? context,
    String fileName = "update.apk",
    bool allowSelfSignedCerts = true,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? secondaryTextColor,
    void Function(DownloadProgress progress)? onProgress,
    void Function(Object error)? onError,
    void Function(OpenResult result)? onInstallResult,
  }) async {
    if (!Platform.isAndroid) {
      await _downloadService.launchExternalDownloadUrl(downloadUrl);
      return null;
    }

    final ValueNotifier<DownloadProgress> progressNotifier =
        ValueNotifier<DownloadProgress>(
      const DownloadProgress(
        receivedBytes: 0,
        totalBytes: 0,
        progress: 0.0,
        statusMessage: "Iniciando descarga...",
      ),
    );

    // Mostrar diálogo de progreso si hay contexto Flutter disponible
    if (context != null && context.mounted) {
      ApkDownloadDialog.show(
        context,
        progressNotifier: progressNotifier,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      );
    }

    try {
      final downloadedFile = await _downloadService.downloadApk(
        url: downloadUrl,
        fileName: fileName,
        allowSelfSignedCerts: allowSelfSignedCerts,
        onProgress: (progress) {
          progressNotifier.value = progress;
          if (onProgress != null) onProgress(progress);
        },
      );

      // Cerrar diálogo al finalizar la descarga
      if (context != null && context.mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Iniciar proceso de instalación nativa
      final result = await _downloadService.installApk(downloadedFile.path);

      if (onInstallResult != null) {
        onInstallResult(result);
      }

      return result;
    } catch (e) {
      if (context != null && context.mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (onError != null) {
        onError(e);
      } else {
        rethrow;
      }
      return null;
    }
  }
}
