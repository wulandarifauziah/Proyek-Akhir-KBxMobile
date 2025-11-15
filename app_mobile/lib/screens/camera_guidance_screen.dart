import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../config/routes.dart';

class CameraGuidanceScreen extends StatefulWidget {
  const CameraGuidanceScreen({super.key});

  @override
  State<CameraGuidanceScreen> createState() => _CameraGuidanceScreenState();
}

class _CameraGuidanceScreenState extends State<CameraGuidanceScreen> {
  bool _isFocusGood = false;
  bool _isLightingGood = false;
  bool _isDistanceGood = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Simulasi pengecekan kualitas gambar yang membaik seiring waktu
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isFocusGood = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLightingGood = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _isDistanceGood = true);
      }
    });
  }

  Future<void> _takePictureAndPredict() async {
    // 1. Tentukan sumber gambar
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      await _sendImageForPrediction(pickedFile);
    }
  }

  // --- FUNGSI BARU: MENGIRIM GAMBAR KE API DJANGO ---
  Future<void> _sendImageForPrediction(XFile imageFile) async {
    // Tampilkan indikator loading/snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengirim gambar untuk identifikasi...')),
      );
    }

    try {
      // Panggil API
      final result = await _apiService.predictImage(imageFile);

      // Ambil hasil prediksi dari model PredictionResult
      final mineralName = result.mineralName;
      final alternatives = result.alternatives;
      // Menggunakan nilai confidence asli dari API
      final double confidence = result.confidence;

      // Hapus snackbar loading
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }

      // ⬅️ START: LOGIKA PENGECEKAN KEPERCAYAAN
      const double confidenceThreshold = 0.95;
      if (confidence < confidenceThreshold) {
        // Tampilkan dialog peringatan jika confidence rendah
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kepercayaan Rendah'),
            content: const Text(
              'Hasil prediksi memiliki tingkat kepercayaan yang rendah. '
              'Silakan coba dengan foto ulang dengan fokus yang lebih tajam dan latar belakang polos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        );
        return; // Hentikan proses lebih lanjut
      }
      // ⬅️ END: LOGIKA PENGECEKAN KEPERCAYAAN

      // Hanya lanjutkan jika confidence >= 0.6
      String? imagePath;
      Uint8List? imageBytes;
      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
      } else {
        imagePath = imageFile.path;
      }

      // Navigasi ke ResultScreen dan kirim data hasilnya
      if (mounted) {
        // Menggunakan pushReplacementNamed agar tidak bisa kembali ke layar kamera dengan tombol back
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.result,
          arguments: {
            'mineralName': mineralName,
            'confidence': confidence,
            'alternatives': alternatives,
            'imagePath': imagePath,
            'imageBytes': imageBytes,
          },
        );
      }
    } catch (e) {
      // Tampilkan pesan error jika prediksi gagal
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Hapus loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Identifikasi. Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool allChecksPassed = _isFocusGood && _isLightingGood && _isDistanceGood;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              color: Colors.grey.shade900,
              alignment: Alignment.center,
              child: const Text(
                'CAMERA PREVIEW\n(Simulasi)',
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: allChecksPassed ? Colors.greenAccent : Colors.white,
                  width: allChecksPassed ? 5 : 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem('Fokus Tajam', _isFocusGood, primaryColor),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Pencahayaan Cukup',
                    _isLightingGood,
                    primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Jarak Ideal (10-20cm)',
                    _isDistanceGood,
                    primaryColor,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: allChecksPassed
                      // ignore: deprecated_member_use
                      ? Colors.greenAccent.withOpacity(0.8)
                      // ignore: deprecated_member_use
                      : Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  allChecksPassed
                      ? 'SIAP DIPINDAI!'
                      : 'Letakkan mineral di dalam kotak',
                  style: TextStyle(
                    color: allChecksPassed ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                InkWell(
                  // BARIS INI SUDAH DIPERBAIKI! Menggunakan fungsi API Anda
                  onTap: allChecksPassed ? _takePictureAndPredict : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: allChecksPassed
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.camera,
                      size: 38,
                      color: allChecksPassed ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 80),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Flash diaktifkan/dinonaktifkan'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isChecked, Color primaryColor) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isChecked ? Colors.greenAccent : Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: isChecked ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
