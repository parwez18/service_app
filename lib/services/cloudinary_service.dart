import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // TODO: Replace with your actual Cloudinary cloud name and unsigned upload preset
  static const String _cloudName = 'dxfl4rdp7';
  static const String _uploadPreset = 'my_photo';

  static Future<String?> uploadImage(
    File imageFile, {
    String folder = 'services',
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final json = jsonDecode(String.fromCharCodes(bytes));
        return json['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
