import 'package:flutter/material.dart';
import '../models/download_progress.dart';

/// Diálogo modal interactivo para mostrar el avance en tiempo real de la descarga del APK.
class ApkDownloadDialog extends StatelessWidget {
  final ValueNotifier<DownloadProgress> progressNotifier;
  final String title;
  final IconData titleIcon;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? secondaryTextColor;

  const ApkDownloadDialog({
    super.key,
    required this.progressNotifier,
    this.title = 'Descargando Actualización',
    this.titleIcon = Icons.downloading,
    this.primaryColor,
    this.backgroundColor,
    this.textColor,
    this.secondaryTextColor,
  });

  /// Muestra el diálogo modal de progreso de forma conveniente.
  static Future<void> show(
    BuildContext context, {
    required ValueNotifier<DownloadProgress> progressNotifier,
    String title = 'Descargando Actualización',
    IconData titleIcon = Icons.downloading,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? secondaryTextColor,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ApkDownloadDialog(
        progressNotifier: progressNotifier,
        title: title,
        titleIcon: titleIcon,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePrimary = primaryColor ?? theme.primaryColor;
    final activeBackground = backgroundColor ?? theme.cardColor;
    final activeText = textColor ?? theme.textTheme.bodyLarge?.color ?? Colors.black;
    final activeSecondaryText =
        secondaryTextColor ?? theme.textTheme.bodyMedium?.color ?? Colors.grey[700];

    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: activeBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(titleIcon, color: activePrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: activeText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: ValueListenableBuilder<DownloadProgress>(
          valueListenable: progressNotifier,
          builder: (context, progress, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.statusMessage,
                  style: TextStyle(
                    color: activeSecondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress.progress > 0 ? progress.progress : null,
                      backgroundColor: activePrimary.withValues(alpha: 0.2),
                      color: activePrimary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${progress.percentage}%",
                        style: TextStyle(
                          color: activePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
