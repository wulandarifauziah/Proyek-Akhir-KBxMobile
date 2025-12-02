import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/prediction_model.dart';
import '../config/routes.dart';

// Asumsi: Anda memiliki variabel global 'cameras' yang diinisialisasi
// di main.dart atau diakses sebagai argumen.
List<CameraDescription> cameras = [];

class CameraGuidanceScreen extends StatefulWidget {
  const CameraGuidanceScreen({super.key});

  @override
  State<CameraGuidanceScreen> createState() => _CameraGuidanceScreenState();
}

class _CameraGuidanceScreenState extends State<CameraGuidanceScreen> {
  late CameraController _controller;
  bool _isControllerReady = false;
  bool _isCameraInitialized = false;

  // HANYA ini yang akan mengontrol tampilan loading/disable di tombol jepret.
  bool _isManualCaptureInProgress = false;

  // Flag baru untuk mencegah live prediction memanggil API berturut-turut
  bool _isLivePredictionInProgress = false;

  bool _isFlashOn = false;
  Timer? _livePredictionTimer;
  final ApiService _apiService = ApiService();

  // Variabel untuk panduan visual (simulasi fokus, cahaya, jarak)
  bool _isFocusGood = false;
  bool _isLightingGood = false;
  bool _isDistanceGood = false;
  // State untuk menyimpan hasil prediksi live
  PredictionResult? _livePredictionResult;

  // GETTER: Cek apakah semua kondisi panduan sudah terpenuhi
  bool get _isGuidanceGood =>
      _isFocusGood && _isLightingGood && _isDistanceGood;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeCamera();
    }
    _simulateGuidanceUpdates();
  }

  // Fungsi simulasi untuk mengaktifkan panduan
  void _simulateGuidanceUpdates() {
    // Simulasi panduan aktif
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isFocusGood = true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLightingGood = true);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _isDistanceGood = true);
    });

    // Simulasi panduan terganggu dan kembali normal
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isDistanceGood = false); // Objek keluar
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) setState(() => _isDistanceGood = true); // Objek masuk lagi
    });
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        cameras = await availableCameras();
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isControllerReady = true;
          _isCameraInitialized = true;
          _startLivePrediction();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isControllerReady = false);
      }
      debugPrint('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal inisialisasi kamera. Periksa izin.'),
        ),
      );
    }
  }

  // FUNGSI UNTUK MEMULAI LIVE PREDICTION TIMER
  void _startLivePrediction() {
    _livePredictionTimer?.cancel();

    if (!_isControllerReady || kIsWeb) return;

    // Ambil gambar dan prediksi setiap 2 detik
    _livePredictionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Live prediction hanya berjalan jika kondisi bagus DAN tidak ada proses live yang sedang berlangsung
      if (_isGuidanceGood && !_isLivePredictionInProgress) {
        _takePictureAndPredict(isLive: true);
      } else if (_livePredictionResult != null) {
        // Hapus hasil prediksi jika kondisi panduan tidak terpenuhi (objek keluar/buram/gelap)
        if (mounted && !_isGuidanceGood) {
          setState(() {
            _livePredictionResult = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _livePredictionTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (!_isControllerReady) return;
    try {
      final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller.setFlashMode(newMode);
      setState(() {
        _isFlashOn = newMode == FlashMode.torch;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  // =========================================================================
  // FUNGSI UTAMA: Ambil Gambar dan Prediksi
  // =========================================================================
  Future<void> _takePictureAndPredict({required bool isLive}) async {
    if (!_isControllerReady) return;

    // Mencegah Live Prediction bertabrakan
    if (isLive && _isLivePredictionInProgress) return;

    // Mencegah Manual Capture bertabrakan
    if (!isLive && _isManualCaptureInProgress) return;

    // Jika ini jepretan final (manual), pastikan kondisi panduan terpenuhi
    if (!isLive && !_isGuidanceGood) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jepretan Gagal: Posisikan objek di kotak dengan fokus dan cahaya yang baik! 🛑',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 1. Atur status loading manual atau live
    setState(() {
      if (!isLive) {
        _isManualCaptureInProgress = true; // Aktifkan loading di tombol jepret
        _livePredictionTimer
            ?.cancel(); // Hentikan live prediction saat capture manual
        _livePredictionResult = null;
      } else {
        _isLivePredictionInProgress = true; // Aktifkan flag live prediction
      }
    });

    String? tempImagePath;

    try {
      // Tampilkan notifikasi loading hanya untuk manual capture
      if (!isLive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gambar sedang diidentifikasi, mohon tunggu hasilnya... ⏳',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }

      // 2. Ambil gambar (Jepret)
      final XFile image = await _controller.takePicture();
      tempImagePath = image.path;

      // 3. Panggil API Service
      final PredictionResult result = await _apiService.predictImage(image);

      if (mounted) {
        // 4. Hapus notifikasi loading (untuk mode final)
        if (!isLive) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        if (isLive) {
          // MODE LIVE: Update hasil prediksi live di UI
          setState(() {
            _livePredictionResult = result;
          });
        } else {
          // 5. MODE FINAL - Navigasi ke ResultScreen
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.result,
            arguments: {
              'mineralName': result.mineralName,
              'confidence': result.confidence,
              'imagePath': tempImagePath,
              'alternatives': result.alternatives
                  .map((a) => a.toJson())
                  .toList(),
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Error during picture capture or prediction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar: ${e.toString()} ❌')),
        );
      }
    } finally {
      // 6. PASTIKAN STATUS LOADING DI-RESET
      if (mounted) {
        setState(() {
          if (!isLive) {
            _isManualCaptureInProgress =
                false; // Reset status loading tombol manual
          } else {
            _isLivePredictionInProgress = false; // Reset flag live prediction
          }
        });
      }
      // Mulai kembali live prediction setelah selesai (baik live maupun manual)
      _startLivePrediction();
    }
  }

  // Fungsi untuk mengambil dari galeri
  Future<void> _pickImageFromGallery() async {
    // Hentikan live prediction saat membuka galeri
    _livePredictionTimer?.cancel();

    // Tampilkan notifikasi loading sementara sebelum API dipanggil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Gambar galeri sedang diidentifikasi, mohon tunggu hasilnya... ⏳',
        ),
        duration: Duration(seconds: 4),
      ),
    );

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final PredictionResult result = await _apiService.predictImage(image);
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.result,
            arguments: {
              'mineralName': result.mineralName,
              'confidence': result.confidence,
              'imagePath': image.path,
              'alternatives': result.alternatives
                  .map((a) => a.toJson())
                  .toList(),
            },
          );
        }
      } catch (e) {
        debugPrint('Error processing gallery image: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memproses gambar galeri: $e ❌')),
          );
        }
      } finally {
        // Mulai lagi live prediction setelah proses galeri selesai
        _startLivePrediction();
      }
    } else {
      // Jika user membatalkan, sembunyikan loading dan mulai lagi live prediction
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _startLivePrediction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // canTakePicture: Kondisi bagus, siap, dan TIDAK sedang memproses jepretan manual
    final bool canTakePicture =
        _isControllerReady && !_isManualCaptureInProgress && _isGuidanceGood;

    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Camera Preview
          if (_isControllerReady)
            Positioned.fill(child: CameraPreview(_controller))
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Kamera tidak tersedia atau error.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          // 2. Overlay Panduan
          _buildGuidanceOverlay(colorScheme),

          // 3. Overlay Hasil Prediksi Live
          if (_livePredictionResult != null)
            _buildLiveResultOverlay(colorScheme),

          // 4. UI Kontrol Kamera
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              // ignore: deprecated_member_use
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tombol Galeri
                  IconButton(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Tombol Jepret (Manual Capture)
                  GestureDetector(
                    // Tombol HANYA bisa dipencet jika canTakePicture TRUE
                    onTap: canTakePicture
                        ? () => _takePictureAndPredict(isLive: false)
                        : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Ubah warna border menjadi hijau jika panduan bagus
                        border: Border.all(
                          color: _isGuidanceGood
                              ? Colors.greenAccent
                              : Colors.white,
                          width: 4,
                        ),
                        color: Colors.white24,
                      ),
                      child: Center(
                        // Tampilkan loading HANYA jika _isManualCaptureInProgress TRUE
                        child: _isManualCaptureInProgress
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            // Jika TIDAK loading, tampilkan tombol normal.
                            : Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // Warna: Putih penuh jika siap, Putih pudar jika tidak siap
                                  color: canTakePicture
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Tombol Flash
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Tombol Kembali
          Positioned(
            top: 40,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- [Metode _buildGuidanceOverlay, _buildLiveResultOverlay, _buildCheckItem] ---

  Widget _buildGuidanceOverlay(ColorScheme colorScheme) {
    final bool allGood = _isGuidanceGood;

    return Column(
      children: [
        const Spacer(flex: 2),
        Container(
          height: 250,
          width: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: allGood ? Colors.greenAccent : Colors.redAccent,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              allGood
                  ? 'Kondisi Sempurna! Prediksi Aktif'
                  : 'Posisikan Mineral di Sini',
              style: TextStyle(
                color: allGood ? Colors.greenAccent : Colors.white70,
                fontWeight: allGood ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckItem('Fokus Jelas', _isFocusGood, colorScheme.primary),
              _buildCheckItem(
                'Pencahayaan Cukup',
                _isLightingGood,
                colorScheme.primary,
              ),
              _buildCheckItem(
                'Jarak Sesuai (10-15 cm)',
                _isDistanceGood,
                colorScheme.primary,
              ),
              const SizedBox(height: 10),
              const Text(
                'Pastikan latar belakang polos agar prediksi akurat.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildLiveResultOverlay(ColorScheme colorScheme) {
    if (_livePredictionResult == null) return const SizedBox.shrink();

    final result = _livePredictionResult!;
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);
    final isConfident = result.confidence >= 0.6;

    Color confidenceColor = isConfident
        ? Colors.greenAccent
        : Colors.orangeAccent;
    String message = isConfident
        ? 'Terdeteksi: ${result.mineralName}'
        : 'Mungkin: ${result.mineralName}';

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: confidenceColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: confidenceColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Akurasi: $confidencePercent%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isChecked, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
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
      ),
    );
  }
}
