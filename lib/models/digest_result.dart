import 'package:crypt_signature_null_safety/models/certificate.dart';

/// Результат хэширования
class DigestResult {
  /// Сертификат из контейнера с приватным ключем
  final Certificate certificate;

  /// Подписываемые данные
  final String message;

  /// Хэш
  final String digest;

  /// Алгоритм хэширования
  final String digestAlgorithm;

  DigestResult(
      {required this.certificate,
      required this.message,
      required this.digest,
      required this.digestAlgorithm});
}
