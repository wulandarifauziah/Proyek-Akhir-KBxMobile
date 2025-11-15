// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import '../models/prediction_model.dart';

// class ResultScreen extends StatelessWidget {
//   final String mineralName;
//   final double confidence;
//   final String? imagePath;
//   final Uint8List? imageBytes;
//   final List<AlternativePrediction> alternatives;

//   const ResultScreen({
//     super.key,
//     required this.mineralName,
//     required this.confidence,
//     this.imagePath,
//     this.imageBytes,
//     this.alternatives = const <AlternativePrediction>[],
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     Color confidenceColor = confidence >= 0.7
//         ? Colors.green
//         : confidence >= 0.5
//         ? Colors.orange
//         : Colors.red;

//     bool isConfident = confidence >= 0.6;
//     bool hasAlternatives = alternatives.isNotEmpty;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Hasil Identifikasi')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 250,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   // ignore: deprecated_member_use
//                   color: colorScheme.surfaceVariant.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: _buildResultImage(colorScheme),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               const Text(
//                 'Identifikasi Utama',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),

//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   // ignore: deprecated_member_use
//                   color: colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     // ignore: deprecated_member_use
//                     color: colorScheme.primary.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.diamond, size: 40, color: confidenceColor),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Mineral Ditemukan:',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey.shade700,
//                                 ),
//                               ),
//                               Text(
//                                 mineralName.toUpperCase(),
//                                 style: TextStyle(
//                                   fontSize: 34,
//                                   fontWeight: FontWeight.w900,
//                                   color: colorScheme.primary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 30, color: Colors.black12),

//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Tingkat Kepercayaan AI',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black54,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Text(
//                               '${(confidence * 100).toStringAsFixed(1)}%',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: confidenceColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: LinearProgressIndicator(
//                             value: confidence,
//                             minHeight: 14,
//                             backgroundColor: Colors.grey.shade200,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               confidenceColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Peringatan jika akurasi rendah
//               if (!isConfident) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.orange.shade300),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.warning_amber, color: Colors.orange.shade700),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Text(
//                           'Kami kurang yakin. Coba foto ulang dengan fokus yang lebih tajam dan latar belakang polos.',
//                           style: TextStyle(fontSize: 14, color: Colors.black87),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               const SizedBox(height: 24),

//               // ⬅️ PERUBAHAN: Tampilkan ExpansionTile hanya jika ada alternatif
//               if (hasAlternatives)
//                 Card(
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ExpansionTile(
//                     tilePadding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 8,
//                     ),
//                     title: const Text(
//                       'Kemungkinan Mineral Lain',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     children: [
//                       // ⬅️ PERUBAHAN: Iterasi melalui daftar alternatif dari API
//                       ...alternatives.map(
//                         (alt) => _buildAlternativePrediction(
//                           alt.mineralName,
//                           alt.confidence,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Jarak disesuaikan jika ExpansionTile tidak ditampilkan
//               if (hasAlternatives)
//                 const SizedBox(height: 30)
//               else
//                 const SizedBox(height: 24),
//               // SizedBox(
//               //   width: double.infinity,
//               //   height: 56,
//               //   child: ElevatedButton.icon(
//               //     onPressed: () {
//               //       Navigator.pushNamed(
//               //         context,
//               //         '/mineral_detail',
//               //         arguments: {
//               //           'mineralName': mineralName,
//               //           'imagePath': imagePath,
//               //         },
//               //       );
//               //     },
//               if (isConfident)
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(
//                         context,
//                         '/mineral_detail',
//                         arguments: {
//                           'mineralName': mineralName,
//                           'imagePath': imagePath,
//                         },
//                       );
//                     },

//                     icon: const Icon(Icons.info_outline, size: 24),
//                     label: const Text(
//                       'Lihat Detail Mineral',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colorScheme.primary,
//                       foregroundColor: colorScheme.onPrimary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 5,
//                     ),
//                   ),
//                 ),

//               if (isConfident)
//                 const SizedBox(height: 12)
//               else
//                 // Beri jarak lebih jika tombol Detail tidak ada
//                 const SizedBox(height: 24),

//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.camera_alt, size: 24),
//                   label: const Text(
//                     'Pindai Lagi',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: colorScheme.secondary,
//                     side: BorderSide(color: colorScheme.outline, width: 1.5),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAlternativePrediction(String name, double conf) {
//     return ListTile(
//       visualDensity: VisualDensity.compact,
//       leading: const Icon(Icons.blur_circular, size: 18, color: Colors.grey),
//       title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
//       trailing: Text(
//         '${(conf * 100).toStringAsFixed(1)}%',
//         style: const TextStyle(
//           color: Colors.black54,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePlaceholder(ColorScheme colorScheme) {
//     return Container(
//       color: Colors.transparent,
//       alignment: Alignment.center,
//       child: Icon(
//         Icons.image,
//         size: 80,
//         // ignore: deprecated_member_use
//         color: colorScheme.onSurfaceVariant.withOpacity(0.5),
//       ),
//     );
//   }

//   Widget _buildResultImage(ColorScheme colorScheme) {
//     if (imageBytes != null && imageBytes!.isNotEmpty) {
//       return Image.memory(
//         imageBytes!,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             _buildImagePlaceholder(colorScheme),
//       );
//     }
//     if (imagePath != null) {
//       if (kIsWeb) {
//         if (imagePath!.startsWith('http')) {
//           return Image.network(
//             imagePath!,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) =>
//                 _buildImagePlaceholder(colorScheme),
//           );
//         }
//         return _buildImagePlaceholder(colorScheme);
//       }
//       return Image.file(
//         File(imagePath!),
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             _buildImagePlaceholder(colorScheme),
//       );
//     }
//     return _buildImagePlaceholder(colorScheme);
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/prediction_model.dart';
import 'history_screen.dart';
import '../config/routes.dart';

class ResultScreen extends StatefulWidget {
  final String mineralName;
  final double confidence;
  final String? imagePath;
  final Uint8List? imageBytes;
  final List<AlternativePrediction> alternatives;

  const ResultScreen({
    super.key,
    required this.mineralName,
    required this.confidence,
    this.imagePath,
    this.imageBytes,
    this.alternatives = const <AlternativePrediction>[],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Variabel untuk mencegah penyimpanan ganda saat rebuild
  bool _isSaved = false;
  final HistoryService _historyService = HistoryService();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // LOGIKA UTAMA: Panggil fungsi untuk menyimpan hasil ke riwayat saat layar dimuat
    Future.microtask(() => _saveToHistory());
  }

  // Logika penyimpanan data ke HistoryService
  Future<void> _saveToHistory() async {
    if (_isSaved) {
      return;
    }

    try {
      final String? imagePath =
          widget.imagePath != null && widget.imagePath!.isNotEmpty
              ? widget.imagePath
              : null;

      String? imageBase64;
      if (imagePath == null) {
        if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
          imageBase64 = base64Encode(widget.imageBytes!);
        } else {
          debugPrint(
            'Tidak menyimpan ke riwayat: imagePath dan imageBytes tidak tersedia.',
          );
          return;
        }
      }

      final HistoryItem newItem = HistoryItem(
        id: _uuid.v4(), // Generate ID unik
        mineralName: widget.mineralName,
        confidence: widget.confidence,
        imagePath: imagePath,
        imageBase64: imageBase64,
        timestamp: DateTime.now(),
      );

      await _historyService.addHistoryItem(newItem);

      // Tandai sudah disimpan
      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e) {
      debugPrint('Gagal menyimpan ke riwayat: $e');
      if (mounted && kDebugMode) {
        // Hanya tampilkan snackbar error saat development
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan ke riwayat: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color confidenceColor = widget.confidence >= 0.7
        ? Colors.green
        : widget.confidence >= 0.5
            ? Colors.orange
            : Colors.red;

    bool isConfident = widget.confidence >= 0.95;
    bool hasAlternatives = widget.alternatives.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Identifikasi')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildResultImage(colorScheme),
                ),
              ),

              const SizedBox(height: 10),
              // Indikator Penyimpanan Riwayat
              if (_isSaved)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Hasil tersimpan di Riwayat Pemindaian.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              const Text(
                'Identifikasi Utama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.diamond, size: 40, color: confidenceColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mineral Ditemukan:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                widget.mineralName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, color: Colors.black12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tingkat Kepercayaan AI',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(widget.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: confidenceColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: widget.confidence,
                            minHeight: 14,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              confidenceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!isConfident) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kepercayaan Rendah',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Hasil prediksi memiliki tingkat kepercayaan yang rendah. '
                              'Silakan coba dengan foto ulang dengan fokus yang lebih tajam dan latar belakang polos.',
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Tampilkan ExpansionTile hanya jika ada alternatif
              if (hasAlternatives)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    title: const Text(
                      'Kemungkinan Mineral Lain',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      // Iterasi melalui daftar alternatif dari API
                      ...widget.alternatives.map(
                        (alt) => _buildAlternativePrediction(
                          alt.mineralName,
                          alt.confidence,
                        ),
                      ),
                    ],
                  ),
                ),

              // Jarak disesuaikan jika ExpansionTile tidak ditampilkan
              if (hasAlternatives)
                const SizedBox(height: 30)
              else
                const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Pastikan rute '/mineral_detail' sesuai dengan AppRoutes.mineralDetail
                    // Asumsi AppRoutes.mineralDetail diakses melalui AppRoutes.
                    Navigator.of(context).pushNamed(
                      AppRoutes.mineralDetail,
                      arguments: {
                        'mineralName': widget.mineralName,
                        'imagePath': widget.imagePath,
                      },
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 24),
                  label: const Text(
                    'Lihat Detail Mineral',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text(
                    'Pindai Lagi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    side: BorderSide(color: colorScheme.outline, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativePrediction(String name, double conf) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.blur_circular, size: 18, color: Colors.grey),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        '${(conf * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Icon(
        Icons.image,
        size: 80,
        // ignore: deprecated_member_use
        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }

  Widget _buildResultImage(ColorScheme colorScheme) {
    if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImagePlaceholder(colorScheme),
      );
    }
    if (widget.imagePath != null) {
      if (kIsWeb) {
        if (widget.imagePath!.startsWith('http')) {
          return Image.network(
            widget.imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildImagePlaceholder(colorScheme),
          );
        }
        return _buildImagePlaceholder(colorScheme);
      }
      return Image.file(
        File(widget.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImagePlaceholder(colorScheme),
      );
    }
    return _buildImagePlaceholder(colorScheme);
  }
}
