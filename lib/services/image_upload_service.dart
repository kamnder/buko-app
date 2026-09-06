import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Cloudinary unsigned image uploader.
///
/// The client intentionally uses an unsigned upload preset; API secrets must
/// never be shipped inside the Android application.
class ImageUploadService {
  ImageUploadService._();
  static final ImageUploadService instance = ImageUploadService._();

  static const String _cloudName = String.fromEnvironment(
    'BUKO_CLOUDINARY_CLOUD_NAME',
    defaultValue: 'REPLACE_WITH_CLOUD_NAME',
  );
  static const String _uploadPreset = String.fromEnvironment(
    'BUKO_CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'REPLACE_WITH_UNSIGNED_UPLOAD_PRESET',
  );

  Future<String> uploadCarImage(Uint8List bytes, String fileName) async {
    if (_cloudName.startsWith('REPLACE_') || _uploadPreset.startsWith('REPLACE_')) {
      throw StateError('خدمة الصور غير مهيأة بعد. إعدادات Cloudinary ناقصة.');
    }
    if (bytes.isEmpty) throw StateError('ملف الصورة فارغ.');
    if (bytes.length > 10 * 1024 * 1024) {
      throw StateError('حجم الصورة كبير جدًا. الحد الأقصى 10 ميجابايت.');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'buko/cars'
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    try {
      final response = await request.send().timeout(const Duration(seconds: 45));
      final body = await response.stream.bytesToString();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final cloudinaryMessage = _extractCloudinaryMessage(body);
        final normalized = cloudinaryMessage.toLowerCase();

        if (normalized.contains('unknown api key') ||
            normalized.contains('api key null') ||
            normalized.contains('upload preset') && normalized.contains('unsigned')) {
          throw StateError(
            'Cloudinary رفض رفع الصورة: إعداد Upload Preset "$ _uploadPreset" يجب أن يكون Unsigned. '
            'تحقق من إعدادات Cloudinary ثم أعد المحاولة.',
          );
        }

        if (normalized.contains('upload preset') &&
            (normalized.contains('not found') || normalized.contains('does not exist'))) {
          throw StateError(
            'Cloudinary لا يجد Upload Preset "$_uploadPreset". تحقق من اسم الـPreset في إعدادات البناء.',
          );
        }

        throw StateError(cloudinaryMessage.isNotEmpty
            ? cloudinaryMessage
            : 'فشل رفع الصورة (${response.statusCode}).');
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw StateError('استجابة خدمة الصور غير صالحة.');
      }

      final secureUrl = decoded['secure_url']?.toString();
      if (secureUrl == null || secureUrl.isEmpty) {
        throw StateError('لم تُرجع خدمة الصور رابط الصورة.');
      }
      return secureUrl;
    } on TimeoutException {
      throw StateError('انتهت مهلة رفع الصورة. تحقق من اتصال الإنترنت وحاول مرة أخرى.');
    } on SocketException {
      throw StateError('تعذر الاتصال بخدمة الصور. تحقق من اتصال الإنترنت.');
    } on FormatException {
      throw StateError('تعذر قراءة استجابة خدمة الصور.');
    }
  }

  String _extractCloudinaryMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        return (decoded['error']['message'] ?? '').toString().trim();
      }
    } catch (_) {}
    return '';
  }
}
