import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.developer_mode, size: 80, color: colorScheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Informasi Aplikasi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.code),
              title: Text('Versi Model ML'),
              subtitle: Text('V1.0'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Pengembang'),
              subtitle: Text('Kelompok 5 Tim Kecerdasan Buatan x Mobile Apps'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Teknologi'),
              subtitle: Text(
                'Flutter untuk UI dan Python/Django untuk backend AI/ML.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
