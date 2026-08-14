/// Modelo de datos para notificar el estado y progreso de la descarga de un APK.
class DownloadProgress {
  /// Bytes actualmente recibidos.
  final int receivedBytes;

  /// Total de bytes a descargar (puede ser -1 o 0 si no se conoce la cabecera Content-Length).
  final int totalBytes;

  /// Progreso expresado como fracción entre 0.0 y 1.0.
  final double progress;

  /// Mensaje descriptivo con el estado actual (ej: "Descargando APK: 4.5 MB de 12.0 MB").
  final String statusMessage;

  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    required this.progress,
    required this.statusMessage,
  });

  /// MB descargados formateados a un decimal.
  String get receivedMb => (receivedBytes / (1024 * 1024)).toStringAsFixed(1);

  /// MB totales formateados a un decimal.
  String get totalMb => totalBytes > 0
      ? (totalBytes / (1024 * 1024)).toStringAsFixed(1)
      : "0.0";

  /// Porcentaje entero (0 a 100).
  int get percentage => (progress * 100).clamp(0, 100).toInt();
}
