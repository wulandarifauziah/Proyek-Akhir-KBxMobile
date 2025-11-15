import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_model.dart';

class ApiService {
  static const String _baseUrl = "https://pakbmobile.loca.lt";

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _predictUri {
    return Uri.parse("$_baseUrl/api/predict-image");
  }

  Future<PredictionResult> predictImage(XFile imageFile) async {
    final mediaType = _resolveMediaType(imageFile.name);

    const Duration requestTimeout = Duration(seconds: 20);
    int attempt = 0;
    http.Response response;

    while (true) {
      attempt += 1;

      try {
        final request = http.MultipartRequest('POST', _predictUri)
          ..headers['Accept'] = 'application/json';

        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: imageFile.name,
              contentType: mediaType,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageFile.path,
              contentType: mediaType,
            ),
          );
        }

        print("API POST $_predictUri (attempt=$attempt)");

        final streamed = await _client.send(request).timeout(requestTimeout);

        response = await http.Response.fromStream(streamed);
        print("API response ${response.statusCode}: ${response.body}");
        break;
      } catch (e) {
        if (attempt >= 2) {
          throw Exception("Gagal menghubungi server LocalTunnel: $e");
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return PredictionResult.fromJson(decoded);
    }

    throw Exception(
      "Server mengembalikan error (${response.statusCode}): ${response.body}",
    );
  }

  MediaType _resolveMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.heic')) return MediaType('image', 'heic');
    return MediaType('image', 'jpeg');
  }
}
