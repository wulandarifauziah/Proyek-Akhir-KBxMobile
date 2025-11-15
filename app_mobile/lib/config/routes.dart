import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/camera_guidance_screen.dart';
import '../screens/result_screen.dart';
import '../screens/mineral_detail_screen.dart';
import '../models/prediction_model.dart';
import '../screens/catalog_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_view.dart';

class AppRoutes {
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String cameraGuidance = '/camera_guidance';
  static const String result = '/result';
  static const String mineralDetail = '/mineral_detail';
  static const String catalog = '/catalog';
  static const String history = '/history';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    onboarding: (context) => const OnboardingScreen(),
    cameraGuidance: (context) => const CameraGuidanceScreen(),
    catalog: (context) => const CatalogScreen(),
    history: (context) => const HistoryScreen(),
    settings: (context) => const SettingsView(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case result:
        final args = settings.arguments as Map<String, dynamic>?;

        final dynamic confidenceValue = args?['confidence'];
        final double confidence = confidenceValue is num
            ? confidenceValue.toDouble()
            : 0.0;
        final String mineralName = args?['mineralName'] as String? ?? 'Unknown';
        // Parse alternatives safely: could be List<AlternativePrediction> or a List<Map>
        final rawAlts = args?['alternatives'];
        final List<AlternativePrediction> alternativesList = [];
        if (rawAlts is List) {
          for (final e in rawAlts) {
            if (e is AlternativePrediction) {
              alternativesList.add(e);
            } else if (e is Map<String, dynamic>) {
              alternativesList.add(AlternativePrediction.fromJson(e));
            }
          }
        }

        Uint8List? imageBytes;
        final rawBytes = args?['imageBytes'];
        if (rawBytes is Uint8List) {
          imageBytes = rawBytes;
        } else if (rawBytes is List<int>) {
          imageBytes = Uint8List.fromList(rawBytes);
        }

        return MaterialPageRoute(
          builder: (context) => ResultScreen(
            mineralName: mineralName,
            confidence: confidence,
            imagePath: args?['imagePath'] as String?,
            imageBytes: imageBytes,
            alternatives: alternativesList,
          ),
        );
      case mineralDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => MineralDetailScreen(
            mineralName: args?['mineralName'] as String? ?? 'Unknown',
            imagePath: args?['imagePath'] as String?,
          ),
        );
      default:
        return null;
    }
  }
}
