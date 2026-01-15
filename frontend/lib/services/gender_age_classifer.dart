// lib/services/gender_age_classifier.dart

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import '../models/detection_result.dart';

class GenderAgeClassifier {
  Interpreter? _genderInterpreter;
  Interpreter? _ageInterpreter;
  bool _isInitialized = false;
  String? _lastPredictedGender;

  static const int ageInputSize = 200;
  static const int genderInputSize = 128;
  static const int numChannels = 3;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🧠 Loading TFLite models...');

      _genderInterpreter = await Interpreter.fromAsset(
        'assets/models/model_gender_q.tflite',
      );
      print('✅ Gender model loaded');

      _ageInterpreter = await Interpreter.fromAsset(
        'assets/models/model_age_q.tflite',
      );
      print('✅ Age model loaded');

      _isInitialized = true;
    } catch (e) {
      print('❌ Failed to load models: $e');
      print('⚠️  Fallback: Using mock classification');
    }
  }

  Float32List _preprocessImage(img.Image face, int targetSize) {
    final grayscale = img.grayscale(face);

    final resized = img.copyResize(
      grayscale,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.cubic,
    );

    final normalized = img.adjustColor(resized, contrast: 1.2, brightness: 1.0);

    final input = Float32List(1 * targetSize * targetSize * 3);

    var pixelIndex = 0;
    for (var y = 0; y < targetSize; y++) {
      for (var x = 0; x < targetSize; x++) {
        final pixel = normalized.getPixel(x, y);

        final r = (pixel.r / 255.0 - 0.5) * 2.0;
        final g = (pixel.g / 255.0 - 0.5) * 2.0;
        final b = (pixel.b / 255.0 - 0.5) * 2.0;

        input[pixelIndex++] = r;
        input[pixelIndex++] = g;
        input[pixelIndex++] = b;
      }
    }

    return input;
  }

  Future<Map<String, dynamic>> classify(img.Image face) async {
    if (!_isInitialized ||
        _genderInterpreter == null ||
        _ageInterpreter == null) {
      return _mockClassification();
    }

    try {
      final genderInput = _preprocessImage(face, genderInputSize);

      final genderInputReshaped = genderInput.reshape([
        1,
        genderInputSize,
        genderInputSize,
        3,
      ]);
      var genderOutput = List.filled(1 * 2, 0.0).reshape([1, 2]);

      _genderInterpreter!.run(genderInputReshaped, genderOutput);

      final prob0 = genderOutput[0][0];
      final prob1 = genderOutput[0][1];

      print(
        '📊 Raw output: Male=${prob0.toStringAsFixed(3)}, Female=${prob1.toStringAsFixed(3)}',
      );

      final isMale = prob0 > prob1;
      final gender = isMale ? 'male' : 'female';
      final genderConfidence = isMale ? prob0 : prob1;

      _lastPredictedGender = gender;

      final ageInput = _preprocessImage(face, ageInputSize);

      final ageInputReshaped = ageInput.reshape([
        1,
        ageInputSize,
        ageInputSize,
        3,
      ]);
      var ageOutput = List.filled(1 * 1, 0.0).reshape([1, 1]);

      _ageInterpreter!.run(ageInputReshaped, ageOutput);

      final normalizedAge = ageOutput[0][0];
      final estimatedAge = (normalizedAge * 116).round().clamp(0, 116);
      final ageGroup = AgeEstimator.estimateAgeGroup(estimatedAge);

      print(
        '🎯 Gender: $gender (${(genderConfidence * 100).toStringAsFixed(1)}%), Age: $estimatedAge ($ageGroup)',
      );

      return {
        'gender': gender,
        'age_group': ageGroup,
        'estimated_age': estimatedAge,
        'confidence': genderConfidence,
      };
    } catch (e) {
      print('❌ Classification failed: $e');
      return _mockClassification();
    }
  }

  Map<String, dynamic> _mockClassification() {
    final random = DateTime.now().millisecond;
    final gender = random % 2 == 0 ? 'male' : 'female';
    final age = 20 + (random % 40);
    final ageGroup = AgeEstimator.estimateAgeGroup(age);

    print('🎲 MOCK: Gender=$gender, Age=$age ($ageGroup)');

    return {
      'gender': gender,
      'age_group': ageGroup,
      'estimated_age': age,
      'confidence': 0.75,
    };
  }

  Future<void> dispose() async {
    _genderInterpreter?.close();
    _ageInterpreter?.close();
    _isInitialized = false;
    print('🔴 Models disposed');
  }

  bool get isInitialized => _isInitialized;
}
