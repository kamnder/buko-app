import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Cloudinary unsigned image uploader.
///
/// Configure these two values before production builds with dart-define.
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
      throw StateError('خدمة الصور غير مهيأة بعد. أضف إعدادات Cloudinary.');
    }
    if (bytes.isEmpty) throw StateError('ملف الصورة فارغ.');

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'buko/cars'
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final response = await request.send().timeout(const Duration(seconds: 45));
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'فشل رفع الصورة (${response.statusCode})';
      try {
        final json = jsonDecode(body);
        if (json is Map && json['error'] is Map) {
          message = (json['error']['message'] ?? message).toString();
        }
      } catch (_) {}
      throw StateError(message);
    }

    final json = jsonDecode(body);
    final secureUrl = json['secure_url']?.toString();
    if (secureUrl == null || secureUrl.isEmpty) {
      throw StateError('لم تُرجع خدمة الصور رابط الصورة.');
    }
    return secureUrl;
  }
}
