import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/routes.dart';
import '../theme/theme_controller.dart';
// ⬅️ DITAMBAHKAN: Perlu diimpor untuk logika API dan model data
import '../services/api_service.dart';
import '../models/prediction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  Future<void> _pickFromGallery() async {
    if (_isLoading) return;

    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }

      // 1. Tampilkan Loading
      setState(() {
        _isLoading = true;
      });

      // 2. Lakukan Panggilan API
      final PredictionResult result = await ApiService().predictImage(image);

      Uint8List? imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      }

      // 3. Tentukan ambang batas kepercayaan (95%)
      const double confidenceThreshold = 0.95;
      if (result.confidence < confidenceThreshold) {
        // Tampilkan dialog peringatan
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

      // 4. Sukses: Navigasi ke ResultScreen
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.result,
        arguments: {
          'mineralName': result.mineralName,
          'confidence': result.confidence,
          'imagePath': kIsWeb ? null : image.path,
          'imageBytes': imageBytes,
          'alternatives': result.alternatives,
        },
      );
    } catch (error) {
      // 5. Gagal: Tampilkan Error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal prediksi: ${error.toString()}')),
      );
    } finally {
      // 6. Sembunyikan Loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tips Penggunaan'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _TipItem('Gunakan pencahayaan yang cukup'),
              _TipItem('Foto dari jarak 10-20 cm'),
              _TipItem('Pastikan fokus tajam pada objek'),
              _TipItem('Hindari bayangan yang menutupi objek'),
              _TipItem('Letakkan mineral di latar belakang polos'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeController = ThemeControllerScope.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/latar.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.55,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            color: colorScheme.surface.withValues(
              alpha: isDarkMode ? 0.78 : 0.6,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Bagian header dan tombol setting, history, dll. tidak diubah)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/logo_geoscan.png', height: 52),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.settings,
                              ),
                              icon: Icon(
                                Icons.settings,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.history,
                              ),
                              icon: Icon(
                                Icons.history,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            IconButton(
                              onPressed: () => themeController.toggle(),
                              icon: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: colorScheme.onSurface,
                              ),
                              tooltip: isDarkMode
                                  ? 'Mode Terang'
                                  : 'Mode Gelap',
                            ),
                            IconButton(
                              onPressed: () => _showTipsDialog(context),
                              icon: Icon(
                                Icons.help_outline,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Identifikasi Mineral',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Arahkan kamera ke objek mineral untuk analisa otomatis oleh AI',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.science_outlined,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    title: 'Buka Kamera',
                    subtitle: 'Foto langsung dari kamera',
                    onTap: _isLoading
                        ? () {}
                        : () => Navigator.pushNamed(
                            context,
                            AppRoutes.cameraGuidance,
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.upload_file,
                    title: 'Upload Gambar',
                    subtitle: _isLoading ? 'Memproses...' : 'Pilih dari galeri',
                    onTap: () => _pickFromGallery(),
                  ),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Detail Mineral yang Anda Harus Tahu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Koleksi lengkap 5 jenis mineral, dapat anda lihat. Klik tombol dibawah ini untuk mengetahui secara detail',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.catalog),
                          icon: const Icon(Icons.book, size: 24),
                          label: const Text(
                            'Lihat Katalog Mineral',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
