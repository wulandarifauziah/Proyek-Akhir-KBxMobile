import 'dart:io';
import 'package:flutter/material.dart';

class MineralDetailScreen extends StatelessWidget {
  final String mineralName;
  final String? imagePath;

  const MineralDetailScreen({
    super.key,
    required this.mineralName,
    this.imagePath,
  });

  static const Map<String, dynamic> _mineralDetails = {
    'Pyrite': {
      'formula': 'FeS₂ (Besi Sulfida)',
      'summary':
          'Pyrite adalah mineral sulfida besi yang paling umum. Sering disebut "emas bodoh" karena warnanya yang mirip emas. Ditemukan di berbagai lingkungan geologis.',
      'physic': [
        {'label': 'Kekerasan (Mohs)', 'value': '6 - 6.5'},
        {'label': 'Warna', 'value': 'Kuning keemasan pucat'},
        {'label': 'Kilap', 'value': 'Metalik'},
        {'label': 'Gores', 'value': 'Hijau kehitaman'},
        {'label': 'Kepadatan', 'value': '4.95 - 5.10 g/cm³'},
      ],
      'crystal': [
        {'label': 'Sistem Kristal', 'value': 'Kubik'},
        {
          'label': 'Bentuk',
          'value': 'Kubus, Oktahedron, Pentoagonal Dodecahedron',
        },
        {'label': 'Belahan', 'value': 'Tidak sempurna (conchoidal)'},
      ],
      'uses':
          '• Produksi asam sulfat (H₂SO₄)\n• Sebagai bijih besi (minor)\n• Koleksi mineral dan perhiasan (terutama kristal kubus yang sempurna)',
      'location':
          'Pyrite ditemukan di seluruh dunia, termasuk di pertambangan Peru, Spanyol (Navajún), Italia, dan berbagai lokasi di Amerika Serikat.',
    },
    'Azurite': {
      'formula': 'Cu₃(CO₃)₂(OH)₂ (Tembaga Karbonat)',
      'summary':
          'Azurite adalah mineral tembaga karbonat yang terkenal dengan warna biru tua yang cerah. Sering ditemukan bersama Malachite dan digunakan sebagai bijih tembaga minor dan pigmen.',
      'physic': [
        {'label': 'Kekerasan (Mohs)', 'value': '3.5 - 4'},
        {'label': 'Warna', 'value': 'Biru langit hingga biru tua'},
        {'label': 'Kilap', 'value': 'Vitreous (kaca) hingga kusam'},
        {'label': 'Gores', 'value': 'Biru muda'},
        {'label': 'Kepadatan', 'value': '3.77 - 3.89 g/cm³'},
      ],
      'crystal': [
        {'label': 'Sistem Kristal', 'value': 'Monoklinik'},
        {'label': 'Bentuk', 'value': 'Pristmatik'},
        {'label': 'Belahan', 'value': 'Sempurna'},
      ],
      'uses':
          '• Bijih tembaga minor\n• Pigmen alami (Azure blue)\n• Batu perhiasan dan koleksi mineral',
      'location':
          'Tersebar di banyak lokasi tembaga, termasuk Arizona (AS), Chili, dan Prancis.',
    },
    'Calcite': {
      'formula': 'CaCO₃ (Kalsium Karbonat)',
      'summary':
          'Calcite adalah salah satu mineral yang paling umum, pembentuk utama batu gamping dan marmer. Dikenal karena sifat bi-refringence (pembiakan ganda) yang kuat.',
      'physic': [
        {'label': 'Kekerasan (Mohs)', 'value': '3'},
        {
          'label': 'Warna',
          'value': 'Bervariasi (putih, bening, abu-abu, dll.)',
        },
        {'label': 'Kilap', 'value': 'Vitreous (kaca) hingga mutiara'},
        {'label': 'Gores', 'value': 'Putih'},
        {'label': 'Kepadatan', 'value': '2.71 g/cm³'},
      ],
      'crystal': [
        {'label': 'Sistem Kristal', 'value': 'Trigonal'},
        {'label': 'Bentuk', 'value': 'Rhombohedron, Skalenohedron'},
        {'label': 'Belahan', 'value': 'Sempurna (rhombohedral)'},
      ],
      'uses':
          '• Bahan bangunan (semen, kapur)\n• Penetrasi sumur minyak dan gas\n• Netralisasi asam',
      'location':
          'Ditemukan di seluruh dunia di batuan sedimen, metamorf, dan hidrotermal.',
    },
    'Copper': {
      'formula': 'Cu (Tembaga)',
      'summary':
          'Tembaga adalah salah satu dari sedikit unsur yang muncul secara alami dalam bentuk murni, dikenal karena konduktivitas listrik dan panasnya yang tinggi.',
      'physic': [
        {'label': 'Kekerasan (Mohs)', 'value': '2.5 - 3'},
        {
          'label': 'Warna',
          'value': 'Merah tembaga, sering ternoda menjadi hijau',
        },
        {'label': 'Kilap', 'value': 'Metalik'},
        {'label': 'Gores', 'value': 'Merah tembaga'},
        {'label': 'Kepadatan', 'value': '8.94 g/cm³'},
      ],
      'crystal': [
        {'label': 'Sistem Kristal', 'value': 'Kubik'},
        {
          'label': 'Bentuk',
          'value': 'Dodecahedron, massa dendritik atau kawat',
        },
        {'label': 'Belahan', 'value': 'Tidak ada'},
      ],
      'uses':
          '• Kawat dan kabel listrik\n• Pipa ledeng\n• Komponen paduan (kuningan, perunggu)',
      'location':
          'Tersebar luas di Amerika Serikat (Michigan), Chile, dan Australia.',
    },
    'Hematite': {
      'formula': 'Fe₂O₃ (Besi(III) Oksida)',
      'summary':
          'Hematite adalah mineral bijih besi yang paling penting. Namanya berasal dari bahasa Yunani yang berarti "darah" karena goresannya berwarna merah darah.',
      'physic': [
        {'label': 'Kekerasan (Mohs)', 'value': '5 - 6.5'},
        {
          'label': 'Warna',
          'value': 'Abu-abu kehitaman, merah bata (tergantung bentuk)',
        },
        {'label': 'Kilap', 'value': 'Metalik hingga kusam'},
        {'label': 'Gores', 'value': 'Merah darah'},
        {'label': 'Kepadatan', 'value': '5.26 g/cm³'},
      ],
      'crystal': [
        {'label': 'Sistem Kristal', 'value': 'Trigonal'},
        {
          'label': 'Bentuk',
          'value': 'Kristal tabular, massa reniform, oolitik',
        },
        {'label': 'Belahan', 'value': 'Tidak ada'},
      ],
      'uses':
          '• Sumber utama bijih besi\n• Pigmen (ocher merah)\n• Perhiasan (bentuk specularite)',
      'location':
          'Ditemukan di deposit besar di Brasil, Kanada, Australia, dan Tiongkok.',
    },
    'Malachite': {
      'formula': 'Cu₂(CO₃)(OH)₂ (Tembaga Karbonat)',
      'summary':
          'Malachite adalah mineral tembaga karbonat sekunder yang dikenal karena warna hijau cerahnya yang khas, sering ditemukan bersama Azurite.',
      'physic': [
        {'label': 'Kekerasan (Mohs)', 'value': '3.5 - 4'},
        {'label': 'Warna', 'value': 'Hijau cerah hingga hijau tua'},
        {'label': 'Kilap', 'value': 'Sutra (pada serat), kusam (pada massa)'},
        {'label': 'Gores', 'value': 'Hijau muda'},
        {'label': 'Kepadatan', 'value': '3.9 - 4.03 g/cm³'},
      ],
      'crystal': [
        {'label': 'Sistem Kristal', 'value': 'Monoklinik'},
        {
          'label': 'Bentuk',
          'value': 'Massa botryoidal (seperti anggur), serat radial',
        },
        {'label': 'Belahan', 'value': 'Sempurna (jarang terlihat)'},
      ],
      'uses':
          '• Bijih tembaga minor\n• Batu hias dan perhiasan (terutama yang berpola pita)\n• Pigmen hijau',
      'location':
          'Kongo (Republik Demokratik Kongo), Rusia, Australia, dan AS (Arizona).',
    },
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String assetFileName = '${mineralName.toLowerCase()}.jpg';
    final String defaultAssetPath = 'assets/$assetFileName';

    final String finalImagePath = imagePath ?? defaultAssetPath;

    final detail = _mineralDetails[mineralName] ?? _mineralDetails['Pyrite']!;
    final List<Map<String, String>> physicDetails = (detail['physic'] as List)
        .cast<Map<String, String>>();
    final List<Map<String, String>> crystalDetails = (detail['crystal'] as List)
        .cast<Map<String, String>>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                mineralName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: _buildAppBarBackground(colorScheme, finalImagePath),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mineralName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail['formula'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSection(
                    colorScheme,
                    'Ringkasan',
                    detail['summary'] as String,
                  ),
                  _buildExpandableSection(
                    'Sifat Fisik Utama',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: physicDetails
                          .map(
                            (prop) => _buildPropertyRow(
                              colorScheme,
                              prop['label']!,
                              prop['value']!,
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  _buildExpandableSection(
                    'Karakteristik Kristal',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: crystalDetails
                          .map(
                            (prop) => _buildPropertyRow(
                              colorScheme,
                              prop['label']!,
                              prop['value']!,
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  _buildExpandableSection(
                    'Kegunaan',
                    Text(
                      detail['uses'] as String,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),

                  _buildExpandableSection(
                    'Lokasi Temuan Populer',
                    Text(
                      detail['location'] as String,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ColorScheme colorScheme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const Divider(
          height: 10,
          thickness: 2,
          endIndent: 200,
          color: Colors.teal,
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildExpandableSection(String title, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: content),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(
    ColorScheme colorScheme,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarBackground(ColorScheme colorScheme, String imagePath) {
    if (imagePath.isEmpty) {
      return _buildPlaceholder(colorScheme);
    }

    final bool isAssetImage = imagePath.startsWith('assets/');
    final Widget imageWidget = isAssetImage
        ? Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.terrain,
        size: 120,
        // ignore: deprecated_member_use
        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
      ),
    );
  }
}
