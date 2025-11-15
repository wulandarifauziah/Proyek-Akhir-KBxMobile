import 'package:flutter/material.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static const List<Map<String, String>> _mineralData = [
    {'name': 'Azurite', 'image': 'assets/azurite.jpg'},
    {'name': 'Calcite', 'image': 'assets/calcite.jpg'},
    {'name': 'Copper', 'image': 'assets/copper.jpg'},
    {'name': 'Hematite', 'image': 'assets/hematite.jpg'},
    {'name': 'Malachite', 'image': 'assets/malachite.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Mineral')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mineralData.length,
        itemBuilder: (context, index) {
          final mineral = _mineralData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(mineral['image']!, fit: BoxFit.cover),
                ),
              ),
              title: Text(
                mineral['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text(
                'Lihat detail dan sifat fisik',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/mineral_detail',
                  arguments: {
                    'mineralName': mineral['name']!,
                    'imagePath': mineral['image']!,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
