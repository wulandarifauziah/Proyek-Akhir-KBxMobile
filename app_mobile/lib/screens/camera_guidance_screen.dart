// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/api_service.dart';
// import '../config/routes.dart';

// class CameraGuidanceScreen extends StatefulWidget {
//   const CameraGuidanceScreen({super.key});

//   @override
//   State<CameraGuidanceScreen> createState() => _CameraGuidanceScreenState();
// }

// class _CameraGuidanceScreenState extends State<CameraGuidanceScreen> {
//   bool _isFocusGood = false;
//   bool _isLightingGood = false;
//   bool _isDistanceGood = false;

//   final ApiService _apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     // Simulasi pengecekan kualitas gambar yang membaik seiring waktu
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         setState(() => _isFocusGood = true);
//       }
//     });
//     Future.delayed(const Duration(milliseconds: 1500), () {
//       if (mounted) {
//         setState(() => _isLightingGood = true);
//       }
//     });
//     Future.delayed(const Duration(milliseconds: 2500), () {
//       if (mounted) {
//         setState(() => _isDistanceGood = true);
//       }
//     });
//   }

//   Future<void> _takePictureAndPredict() async {
//     // 1. Tentukan sumber gambar
//     final picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(
//       source: ImageSource.camera,
//     );

//     if (pickedFile != null) {
//       await _sendImageForPrediction(pickedFile);
//     }
//   }

//   // --- FUNGSI BARU: MENGIRIM GAMBAR KE API DJANGO ---
//   Future<void> _sendImageForPrediction(XFile imageFile) async {
//     // Tampilkan indikator loading/snackbar
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Mengirim gambar untuk identifikasi...')),
//       );
//     }

//     try {
//       // Panggil API
//       final result = await _apiService.predictImage(imageFile);

//       // Ambil hasil prediksi dari model PredictionResult
//       final mineralName = result.mineralName;
//       final alternatives = result.alternatives;
//       // Menggunakan nilai confidence asli dari API
//       final double confidence = result.confidence;

//       // Hapus snackbar loading
//       if (mounted) {
//         ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       }

//       // ⬅️ START: LOGIKA PENGECEKAN KEPERCAYAAN
//       const double confidenceThreshold = 0.95;
//       if (confidence < confidenceThreshold) {
//         // Tampilkan dialog peringatan jika confidence rendah
//         if (!mounted) return;
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Kepercayaan Rendah'),
//             content: const Text(
//               'Hasil prediksi memiliki tingkat kepercayaan yang rendah. '
//               'Silakan coba dengan foto ulang dengan fokus yang lebih tajam dan latar belakang polos.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Mengerti'),
//               ),
//             ],
//           ),
//         );
//         return; // Hentikan proses lebih lanjut
//       }
//       // ⬅️ END: LOGIKA PENGECEKAN KEPERCAYAAN

//       // Hanya lanjutkan jika confidence >= 0.6
//       String? imagePath;
//       Uint8List? imageBytes;
//       if (kIsWeb) {
//         imageBytes = await imageFile.readAsBytes();
//       } else {
//         imagePath = imageFile.path;
//       }

//       // Navigasi ke ResultScreen dan kirim data hasilnya
//       if (mounted) {
//         // Menggunakan pushReplacementNamed agar tidak bisa kembali ke layar kamera dengan tombol back
//         Navigator.of(context).pushReplacementNamed(
//           AppRoutes.result,
//           arguments: {
//             'mineralName': mineralName,
//             'confidence': confidence,
//             'alternatives': alternatives,
//             'imagePath': imagePath,
//             'imageBytes': imageBytes,
//           },
//         );
//       }
//     } catch (e) {
//       // Tampilkan pesan error jika prediksi gagal
//       if (mounted) {
//         ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Hapus loading
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal Identifikasi. Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool allChecksPassed = _isFocusGood && _isLightingGood && _isDistanceGood;
//     final primaryColor = Theme.of(context).colorScheme.primary;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Center(
//             child: Container(
//               color: Colors.grey.shade900,
//               alignment: Alignment.center,
//               child: const Text(
//                 'CAMERA PREVIEW\n(Simulasi)',
//                 style: TextStyle(color: Colors.white70, fontSize: 18),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),

//           Center(
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: allChecksPassed ? Colors.greenAccent : Colors.white,
//                   width: allChecksPassed ? 5 : 3,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//           ),

//           Positioned(
//             top: 60,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 // ignore: deprecated_member_use
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildCheckItem('Fokus Tajam', _isFocusGood, primaryColor),
//                   const SizedBox(height: 8),
//                   _buildCheckItem(
//                     'Pencahayaan Cukup',
//                     _isLightingGood,
//                     primaryColor,
//                   ),
//                   const SizedBox(height: 8),
//                   _buildCheckItem(
//                     'Jarak Ideal (10-20cm)',
//                     _isDistanceGood,
//                     primaryColor,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           Positioned(
//             top: 240,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: allChecksPassed
//                       // ignore: deprecated_member_use
//                       ? Colors.greenAccent.withOpacity(0.8)
//                       // ignore: deprecated_member_use
//                       : Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   allChecksPassed
//                       ? 'SIAP DIPINDAI!'
//                       : 'Letakkan mineral di dalam kotak',
//                   style: TextStyle(
//                     color: allChecksPassed ? Colors.black : Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 InkWell(
//                   // BARIS INI SUDAH DIPERBAIKI! Menggunakan fungsi API Anda
//                   onTap: allChecksPassed ? _takePictureAndPredict : null,
//                   child: Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: primaryColor,
//                       border: Border.all(color: Colors.white, width: 4),
//                       boxShadow: allChecksPassed
//                           ? [
//                               BoxShadow(
//                                 // ignore: deprecated_member_use
//                                 color: Colors.greenAccent.withOpacity(0.5),
//                                 blurRadius: 15,
//                                 spreadRadius: 5,
//                               ),
//                             ]
//                           : [],
//                     ),
//                     child: Icon(
//                       Icons.camera,
//                       size: 38,
//                       color: allChecksPassed ? Colors.white : Colors.white54,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(
//                         Icons.arrow_back,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                     const SizedBox(width: 80),
//                     IconButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Flash diaktifkan/dinonaktifkan'),
//                           ),
//                         );
//                       },
//                       icon: const Icon(
//                         Icons.flash_on,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckItem(String label, bool isChecked, Color primaryColor) {
//     return Row(
//       children: [
//         Icon(
//           isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
//           color: isChecked ? Colors.greenAccent : Colors.white70,
//           size: 20,
//         ),
//         const SizedBox(width: 10),
//         Text(
//           label,
//           style: TextStyle(
//             color: isChecked ? Colors.white : Colors.white70,
//             fontSize: 16,
//             fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // lib/screens/camera_guidance_screen.dart
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// // import 'package:path_provider/path_provider.dart'; // Sudah tidak digunakan, bisa dihapus
// import '../services/api_service.dart';
// import '../models/prediction_model.dart';
// import '../config/routes.dart';

// // Variabel global untuk daftar kamera yang tersedia (diisi di main.dart)
// late List<CameraDescription> cameras;

// // --- UTILITY FUNCTION: Inisialisasi Kamera ---
// Future<void> initializeCameras() async {
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//     cameras = await availableCameras();
//     debugPrint('✅ Kameras terdeteksi: ${cameras.length} kamera.');
//   } on CameraException catch (e) {
//     debugPrint('❌ Error in camera initialization: $e');
//     cameras = [];
//   } catch (e) {
//     cameras = [];
//     debugPrint('❌ No cameras available or other error: $e');
//   }
// }

// // =========================================================
// // CAMERA GUIDANCE SCREEN (LIVE PREDICTION)
// // =========================================================

// class CameraGuidanceScreen extends StatefulWidget {
//   const CameraGuidanceScreen({super.key});

//   @override
//   State<CameraGuidanceScreen> createState() => _CameraGuidanceScreenState();
// }

// class _CameraGuidanceScreenState extends State<CameraGuidanceScreen> {
//   // 1. Variabel Kamera
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _isControllerReady = false;
//   bool _isFlashOn = false;

//   // 2. Variabel Live Prediction
//   PredictionResult? _currentPrediction;
//   Timer? _livePredictionTimer;
//   bool _isPredictingLive = false;

//   // Variabel Panduan Simulasi
//   bool _isFocusGood = false;
//   bool _isLightingGood = false;
//   bool _isDistanceGood = false;

//   // Instance API Service
//   final ApiService _apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera().then((_) {
//       if (_isControllerReady) {
//         _startLivePredictionTimer();
//       }
//     });

//     // Logika simulasi panduan
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) setState(() => _isFocusGood = true);
//     });
//     Future.delayed(const Duration(milliseconds: 1500), () {
//       if (mounted) setState(() => _isLightingGood = true);
//     });
//     Future.delayed(const Duration(milliseconds: 2500), () {
//       if (mounted) setState(() => _isDistanceGood = true);
//     });
//   }

//   // --- LOGIKA KAMERA ---
//   Future<void> _initializeCamera() async {
//     if (cameras.isEmpty) {
//       debugPrint('🚨 Tidak ada kamera yang terdeteksi. Navigasi kembali.');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Tidak ada kamera yang tersedia.')),
//         );
//         Navigator.pop(context);
//         return;
//       }
//     }

//     _controller = CameraController(
//       cameras[0],
//       ResolutionPreset.medium,
//       imageFormatGroup: ImageFormatGroup.jpeg,
//     );
//     // Blok try-catch untuk menangkap error inisialisasi controller
//     try {
//       _initializeControllerFuture = _controller.initialize();
//       await _initializeControllerFuture;

//       if (mounted) {
//         setState(() {
//           _isControllerReady = true;
//           _controller.setFlashMode(FlashMode.off);
//         });
//         debugPrint('✅ CameraController siap.');
//       }
//     } on CameraException catch (e) {
//       debugPrint(
//         '❌ Gagal menginisialisasi CameraController: ${e.code} - ${e.description}',
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal inisialisasi kamera: ${e.code}. Cek Izin!'),
//           ),
//         );

//         // 🚨 PERBAIKAN KRUSIAL: Keluar dari layar jika inisialisasi gagal.
//         // Ini mencegah UI terjebak di CircularProgressIndicator.
//         Navigator.pop(context);
//       }
//     }
//   }
//   // ... (Sisa kode _takePictureAndPredict, _toggleFlash, dispose tidak diubah)

//   // --- LOGIKA LIVE PREDICTION ---
//   void _startLivePredictionTimer() {
//     _livePredictionTimer?.cancel();

//     // Ambil gambar dan prediksi setiap 2 detik
//     _livePredictionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted && _isControllerReady && !_isPredictingLive) {
//         _takePictureAndPredict(isLive: true);
//       }
//     });
//   }

//   // --- LOGIKA PENGAMBILAN GAMBAR & PREDIKSI (Dua Mode) ---
//   Future<void> _takePictureAndPredict({required bool isLive}) async {
//     if (!_isControllerReady || _isPredictingLive) return;

//     // Set flag
//     if (mounted) {
//       setState(() {
//         _isPredictingLive = true;
//         if (isLive) _currentPrediction = null;
//       });
//     }

//     String? tempImagePath;

//     try {
//       await _initializeControllerFuture;

//       // ⚠️ PERBAIKAN: Menghapus logika flashMode yang menyebabkan error.
//       // Kami sekarang mengandalkan mode flash yang diatur oleh _toggleFlash.
//       // FlashMode hanya akan diubah melalui tombol _toggleFlash oleh user.
//       final bool wasFlashOn = _isFlashOn;
//       if (!isLive && wasFlashOn) {
//         await _controller.setFlashMode(FlashMode.off);
//       }
//       // Ambil gambar
//       final XFile image = await _controller.takePicture();
//       tempImagePath = image.path;

//       // Jika mode final dan flash sebelumnya aktif, kembalikan ke torch mode
//       if (!isLive && wasFlashOn) {
//         await _controller.setFlashMode(FlashMode.torch);
//       }

//       // Panggil API Service
//       final PredictionResult result = await _apiService.predictImage(image);

//       if (mounted) {
//         if (isLive) {
//           // MODE LIVE: Update UI dan hapus file sementara
//           setState(() {
//             _currentPrediction = result;
//           });
//           if (tempImagePath != null) {
//             // Menghapus file gambar karena ini hanya untuk prediksi live
//             await File(tempImagePath).delete();
//           }
//         } else {
//           // MODE FINAL (tombol ditekan): Navigasi
//           _livePredictionTimer?.cancel();

//           Navigator.of(context).pushReplacementNamed(
//             AppRoutes.result,
//             arguments: {
//               'mineralName': result.mineralName,
//               'confidence': result.confidence,
//               'imagePath': tempImagePath,
//               'alternatives': result.alternatives,
//             },
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Gagal prediksi (Live/Final): $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal prediksi: ${e.toString()}')),
//         );
//       }
//       // Pastikan file dihapus jika terjadi error dalam mode live
//       if (isLive && tempImagePath != null) {
//         await File(tempImagePath).delete();
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isPredictingLive = false;
//         });
//       }
//     }
//   }

//   // --- TOGGLE FLASH ---
//   void _toggleFlash() async {
//     if (!_isControllerReady) return;

//     // Menggunakan FlashMode.torch (sentere) untuk live view
//     final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
//     await _controller.setFlashMode(newFlashMode);

//     if (mounted) {
//       setState(() {
//         _isFlashOn = !_isFlashOn;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Flash ${_isFlashOn ? "diaktifkan" : "dinonaktifkan"}',
//             ),
//             duration: const Duration(milliseconds: 800),
//           ),
//         );
//       });
//     }
//   }

//   // --- DISPOSE ---
//   @override
//   void dispose() {
//     _livePredictionTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   // --- BUILD METHOD ---
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     if (!_isControllerReady) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Kamera')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               children: [
//                 // 1. Camera Preview (Full Screen)
//                 Positioned.fill(child: CameraPreview(_controller)),

//                 // 2. Overlay Panduan (Kotak Fokus)
//                 Center(
//                   child: Container(
//                     width: 250,
//                     height: 250,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.white, width: 2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),

//                 // 3. Overlay Live Prediction dan Kontrol
//                 _buildGuidanceOverlay(colorScheme),

//                 // 4. Tombol Ambil Gambar (Capture Button) - Untuk konfirmasi
//                 Positioned(
//                   bottom: 40,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: FloatingActionButton(
//                       onPressed: () => _takePictureAndPredict(isLive: false),
//                       backgroundColor: colorScheme.primary,
//                       child: Icon(
//                         Icons.camera,
//                         color: colorScheme.onPrimary,
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             // Ini adalah spinner kedua (di dalam FutureBuilder)
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }

//   // --- WIDGET GUIDANCE & LIVE RESULT ---
//   Widget _buildGuidanceOverlay(ColorScheme colorScheme) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.only(
//           left: 20,
//           right: 20,
//           top: 20,
//           bottom: 120,
//         ),
//         decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // HASIL PREDIKSI LIVE
//             _buildLivePredictionResult(),

//             const SizedBox(height: 20),

//             // Tombol Flash dan Kembali
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _toggleFlash,
//                   icon: Icon(
//                     _isFlashOn ? Icons.flash_on : Icons.flash_off,
//                     color: _isFlashOn ? Colors.yellow : Colors.white,
//                     size: 30,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Check List Panduan
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildCheckItem(
//                   'Pastikan mineral mengisi kotak fokus',
//                   _isFocusGood,
//                   colorScheme.primary,
//                 ),
//                 _buildCheckItem(
//                   'Pencahayaan cukup dan merata',
//                   _isLightingGood,
//                   colorScheme.primary,
//                 ),
//                 _buildCheckItem(
//                   'Jarak fokus ideal (tidak buram)',
//                   _isDistanceGood,
//                   colorScheme.primary,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // WIDGET BARU UNTUK LIVE RESULT
//   Widget _buildLivePredictionResult() {
//     final name = _currentPrediction?.mineralName ?? 'Memindai...';
//     final confidence = _currentPrediction?.confidence;

//     String confidenceText;
//     Color confidenceColor;

//     if (confidence != null) {
//       confidenceText = 'Akurasi: ${(confidence * 100).toStringAsFixed(1)}%';
//       confidenceColor = confidence >= 0.7
//           ? Colors.greenAccent
//           : confidence >= 0.5
//           ? Colors.orange
//           : Colors.redAccent;
//     } else {
//       confidenceText = '';
//       confidenceColor = Colors.white;
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           name,
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           confidenceText,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: confidenceColor,
//           ),
//         ),
//         if (_isPredictingLive && confidence == null)
//           const Padding(
//             padding: EdgeInsets.only(top: 8.0),
//             child: SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildCheckItem(String label, bool isChecked, Color primaryColor) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(
//             isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
//             color: isChecked ? Colors.greenAccent : Colors.white70,
//             size: 20,
//           ),
//           const SizedBox(width: 10),
//           Text(
//             label,
//             style: TextStyle(
//               color: isChecked ? Colors.white : Colors.white70,
//               fontSize: 16,
//               fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
