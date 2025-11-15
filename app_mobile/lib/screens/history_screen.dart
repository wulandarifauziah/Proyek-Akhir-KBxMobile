// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/routes.dart';

// ==========================================================
// 1. KELAS MODEL DATA (HistoryItem)
// ==========================================================
class HistoryItem {
  final String id;
  final String mineralName;
  final double confidence;
  final String? imagePath;
  final String? imageBase64;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.mineralName,
    required this.confidence,
    this.imagePath,
    this.imageBase64,
    required this.timestamp,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      mineralName: json['mineralName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imagePath: (json['imagePath'] as String?)?.isNotEmpty == true
          ? json['imagePath'] as String
          : null,
      imageBase64: json['imageBase64'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mineralName': mineralName,
      'confidence': confidence,
      if (imagePath != null) 'imagePath': imagePath,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// ==========================================================
// 2. KELAS LAYANAN (HistoryService)
// ==========================================================
class HistoryService {
  static const String _historyKey = 'scan_history';

  // Menyimpan item riwayat baru (Dipanggil dari ResultScreen)
  Future<void> addHistoryItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingHistoryString = prefs.getString(_historyKey);
    List<HistoryItem> historyList = [];

    if (existingHistoryString != null) {
      try {
        final List<dynamic> historyJson = jsonDecode(existingHistoryString);
        historyList = historyJson
            .whereType<Map<String, dynamic>>()
            .map(HistoryItem.fromJson)
            .toList();
      } catch (e) {
        debugPrint("Error decoding existing history: $e");
      }
    }

    // Tambahkan item baru di posisi paling atas (index 0)
    historyList.insert(0, item);

    final List<Map<String, dynamic>> updatedHistoryJson = historyList
        .map((item) => item.toJson())
        .toList();
    await prefs.setString(_historyKey, jsonEncode(updatedHistoryJson));
  }

  // Mengambil semua item riwayat
  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_historyKey);

    if (historyString == null) {
      return [];
    }

    try {
      final List<dynamic> historyJson = jsonDecode(historyString);
      return historyJson
          .whereType<Map<String, dynamic>>()
          .map(HistoryItem.fromJson)
          .toList();
    } catch (e) {
      debugPrint("Error decoding history: $e");
      return [];
    }
  }

  // Fungsi opsional untuk menghapus semua riwayat
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}

// ==========================================================
// 3. KELAS SCREEN (HistoryScreen)
// ==========================================================
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<HistoryItem> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Memuat data riwayat saat screen dibuka
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    try {
      final list = await _historyService.getHistory();
      if (mounted) {
        // Panggil setState untuk menampilkan data yang dimuat
        setState(() {
          _historyList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading history: $e');
    }
  }

  // Override didChangeDependencies agar data dimuat ulang saat kembali ke layar
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Memastikan kita memuat ulang data saat kembali ke layar ini (misalnya setelah menyimpan di ResultScreen)
    // Walaupun initState sudah memanggil, ini adalah mekanisme yang lebih andal untuk memuat ulang
    // setelah navigasi Pop (kembali).
    if (!_isLoading && _historyList.isEmpty) {
      _loadHistoryData();
    }
  }

  // Fungsi untuk memformat waktu (hh:mm, dd/mm/yyyy)
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      // Tampilkan loading indicator saat data sedang dimuat
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pemindaian')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_historyList.isEmpty) {
      // Tampilkan pesan jika riwayat kosong
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pemindaian')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off,
                size: 80,
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada riwayat pemindaian.',
                style: TextStyle(fontSize: 18, color: colorScheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan daftar riwayat
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemindaian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              // Tambahkan konfirmasi penghapusan
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Riwayat?'),
                  content: const Text(
                    'Anda yakin ingin menghapus semua riwayat pemindaian?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('BATAL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('HAPUS'),
                    ),
                  ],
                ),
              );

              if (!context.mounted) return;

              if (confirmed == true) {
                await _historyService.clearHistory();
                if (!context.mounted) return;
                setState(() {
                  _historyList = [];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua riwayat telah dihapus.')),
                );
              }
            },
          ),
        ],
      ),

      body: ListView.builder(
        // Gunakan _historyList di sini
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final item = _historyList[index];
          ImageProvider? thumbnail;
          if (item.imagePath != null && item.imagePath!.isNotEmpty) {
            final file = File(item.imagePath!);
            if (file.existsSync()) {
              thumbnail = FileImage(file);
            }
          }

          if (thumbnail == null && item.imageBase64 != null) {
            try {
              final bytes = base64Decode(item.imageBase64!);
              if (bytes.isNotEmpty) {
                thumbnail = MemoryImage(Uint8List.fromList(bytes));
              }
            } catch (e) {
              debugPrint('Gagal decode gambar history: $e');
            }
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  // Menampilkan thumbnail gambar dari path lokal
                  child: thumbnail != null
                      ? Image(
                          image: thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : Icon(
                          Icons.image_not_supported,
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          size: 40,
                        ),
                ),
              ),
              title: Text(
                item.mineralName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Akurasi: ${(item.confidence * 100).toStringAsFixed(1)}%\\nDipindai: ${_formatTimestamp(item.timestamp)}',
                style: const TextStyle(fontSize: 13),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Memastikan data dimuat ulang saat kembali
                await Navigator.of(context).pushNamed(
                  AppRoutes.mineralDetail,
                  arguments: {
                    'mineralName': item.mineralName,
                    'imagePath': item.imagePath,
                  },
                );
                // Muat ulang data setelah kembali dari detail screen
                _loadHistoryData();
              },
            ),
          );
        },
      ),
    );
  }
}
