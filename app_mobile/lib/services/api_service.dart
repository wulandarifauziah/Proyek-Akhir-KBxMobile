import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_model.dart';

class ApiService {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
          ? baseUrl
          : (_envBaseUrl.isNotEmpty ? _envBaseUrl : null);

  final http.Client _client;
  final String? _baseUrl;

  Uri get _predictUri {
    if (_baseUrl != null && _baseUrl.isNotEmpty) {
      final clean = _baseUrl.replaceAll(RegExp(r"/+$"), '');
      return Uri.parse('$clean/api/predict-image');
    }

    if (kIsWeb) {
      final base = Uri.base;
      const scheme = 'http';
      final host = base.host.isNotEmpty ? base.host : '127.0.0.1';
      const int defaultPort = 8000;
      return Uri(
        scheme: scheme,
        host: host,
        port: defaultPort,
        path: '/api/predict-image',
      );
    }

    if (Platform.isAndroid) {
      return Uri.parse('http://10.156.90.86:8000/api/predict-image');
      // return Uri.parse('http://192.168.1.5:8000/api/predict-image');
    }

    return Uri.parse('http://127.0.0.1:8000/api/predict-image');
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

        print('API: POST $_predictUri (isWeb=$kIsWeb) attempt=$attempt');

        final streamedResponse = await _client
            .send(request)
            .timeout(requestTimeout);

        response = await http.Response.fromStream(streamedResponse);

        print('API response ${response.statusCode}: ${response.body}');
        break;
      } catch (e) {
        final String err = e.toString();
        if (attempt >= 2) {
          String hint = '';
          if (kIsWeb) {
            final hostHint = Uri.base.host.isNotEmpty
                ? Uri.base.host
                : '127.0.0.1';
            hint =
                'Jika menjalankan pada browser, pastikan server dapat diakses di http://$hostHint:8000 '
                'dan menambahkan header Access-Control-Allow-Origin, atau jalankan aplikasi dengan '
                '--dart-define=API_BASE_URL=http://<IP>:8000.';
          } else if (Platform.isAndroid) {
            hint =
                'Jika menjalankan di emulator Android pastikan server di host dapat diakses melalui 10.0.2.2:8000, '
                'atau berikan baseUrl (mis. ApiService(baseUrl: "http://<IP>:8000")).';
          } else {
            hint =
                'Periksa koneksi jaringan dan bahwa server berjalan pada host yang dapat diakses.';
          }

          throw Exception(
            'Gagal mengirim request ke $_predictUri: $err. $hint',
          );
        }

        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return PredictionResult.fromJson(decoded);
      }
      throw FormatException('Format respons prediksi tidak dikenali');
    }

    String errorDetail = '';
    try {
      final errorJson = jsonDecode(response.body);
      if (errorJson is Map<String, dynamic>) {
        errorDetail = (errorJson['error'] ?? errorJson['detail'] ?? '')
            .toString();
      } else {
        errorDetail = errorJson.toString();
      }
    } catch (_) {
      errorDetail = response.body;
    }

    throw Exception(
      'Gagal mendapatkan prediksi (${response.statusCode}): $errorDetail',
    );
  }

  MediaType _resolveMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lower.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }
    return MediaType('image', 'jpeg');
  }
}
