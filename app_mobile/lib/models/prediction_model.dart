class AlternativePrediction {
  final String mineralName;
  final double confidence;

  const AlternativePrediction({
    required this.mineralName,
    required this.confidence,
  });

  factory AlternativePrediction.fromJson(Map<String, dynamic> json) {
    return AlternativePrediction(
      mineralName: json['mineralName'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'mineralName': mineralName,
    'confidence': confidence,
  };
}

class PredictionResult {
  final String mineralName; // Mineral dengan confidence tertinggi
  final double confidence;
  final List<AlternativePrediction> alternatives;

  PredictionResult({
    required this.mineralName,
    required this.confidence,
    required this.alternatives,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    AlternativePrediction? parseEntry(dynamic entry) {
      if (entry is AlternativePrediction) {
        return entry;
      }
      if (entry is Map<String, dynamic>) {
        final dynamic nameCandidate =
            entry['mineralName'] ?? entry['label'] ?? entry['name'];
        final String? name = nameCandidate is String
            ? nameCandidate
            : nameCandidate?.toString();
        if (name == null || name.isEmpty) {
          return null;
        }
        final dynamic confidenceCandidate =
            entry['confidence'] ??
            entry['score'] ??
            entry['probability'] ??
            entry['value'];
        final double confidence = confidenceCandidate is num
            ? confidenceCandidate.toDouble()
            : 0.0;
        final double normalizedConfidence = confidence > 1
            ? (confidence / 100).clamp(0.0, 1.0)
            : confidence.clamp(0.0, 1.0);
        return AlternativePrediction(
          mineralName: name,
          confidence: normalizedConfidence,
        );
      }
      if (entry is String && entry.isNotEmpty) {
        return AlternativePrediction(mineralName: entry, confidence: 0.0);
      }
      return null;
    }

    final List<AlternativePrediction> alternatives = [];

    String primaryName = (json['mineralName'] as String?)?.trim() ?? '';
    double primaryConfidence =
        (json['confidence'] as num?)?.toDouble() ?? double.nan;

    final predictionField = json['prediction'];
    if (predictionField is List && predictionField.isNotEmpty) {
      final firstEntry = parseEntry(predictionField.first);
      if (firstEntry != null) {
        primaryName = firstEntry.mineralName;
        primaryConfidence = firstEntry.confidence;
      }
      for (var i = 1; i < predictionField.length; i++) {
        final entry = parseEntry(predictionField[i]);
        if (entry == null) continue;
        if (entry.mineralName.toLowerCase() == primaryName.toLowerCase()) {
          continue;
        }
        final index = alternatives.indexWhere(
          (alt) =>
              alt.mineralName.toLowerCase() == entry.mineralName.toLowerCase(),
        );
        if (index >= 0) {
          if (entry.confidence > alternatives[index].confidence) {
            alternatives[index] = entry;
          }
        } else {
          alternatives.add(entry);
        }
      }
    } else if (predictionField is Map<String, dynamic>) {
      final mapped = parseEntry(predictionField);
      if (mapped != null) {
        primaryName = mapped.mineralName;
        primaryConfidence = mapped.confidence;
      }
    } else if (predictionField is String && predictionField.isNotEmpty) {
      if (primaryName.isEmpty) {
        primaryName = predictionField;
      }
    }

    final rawAlternatives = json['alternatives'];
    if (rawAlternatives is List) {
      for (final entry in rawAlternatives) {
        final parsed = parseEntry(entry);
        if (parsed == null) continue;
        if (parsed.mineralName.toLowerCase() == primaryName.toLowerCase()) {
          if (!(primaryConfidence.isFinite && primaryConfidence >= 0)) {
            primaryConfidence = parsed.confidence;
          }
          continue;
        }
        final index = alternatives.indexWhere(
          (alt) =>
              alt.mineralName.toLowerCase() == parsed.mineralName.toLowerCase(),
        );
        if (index >= 0) {
          if (parsed.confidence > alternatives[index].confidence) {
            alternatives[index] = parsed;
          }
        } else {
          alternatives.add(parsed);
        }
      }
    }

    if (primaryName.isEmpty) {
      primaryName = 'Unknown Mineral';
    }

    if (!primaryConfidence.isFinite || primaryConfidence < 0) {
      primaryConfidence = 0.0;
    } else if (primaryConfidence > 1.0) {
      primaryConfidence =
          (primaryConfidence > 100
                  ? primaryConfidence / 100
                  : primaryConfidence)
              .clamp(0.0, 1.0);
    }

    return PredictionResult(
      mineralName: primaryName,
      confidence: primaryConfidence.clamp(0.0, 1.0),
      alternatives: alternatives,
    );
  }
}
