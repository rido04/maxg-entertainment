// lib/services/face_detection_service.dart

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:ui';
import '../models/detection_result.dart';
import '../services/gender_age_classifer.dart';

class FaceDetectionService {
  static FaceDetector? _faceDetector;
  static GenderAgeClassifier? _classifier;
  static CameraController? _cameraController;
  static bool _isInitialized = false;

  // Initialize
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔧 Initializing Face Detection Service...');

      // Initialize ML Kit Face Detector
      final options = FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: true, // For smile detection
        enableTracking: false,
        minFaceSize: 0.15, // Minimum 15% of image
        performanceMode: FaceDetectorMode.fast,
      );
      _faceDetector = FaceDetector(options: options);

      // Initialize Gender/Age Classifier
      _classifier = GenderAgeClassifier();
      await _classifier!.initialize();

      // Initialize Camera
      await _initializeCamera();

      _isInitialized = true;
      print('✅ Face Detection Service initialized');
    } catch (e) {
      print('❌ Failed to initialize Face Detection Service: $e');
      rethrow;
    }
  }

  static Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      // Prefer front camera for passenger detection
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // For better performance
      );

      await _cameraController!.initialize();
      print('📷 Camera initialized: ${camera.name}');
    } catch (e) {
      print('❌ Camera initialization failed: $e');
      rethrow;
    }
  }

  // Detect face and classify gender/age
  static Future<DetectionResult> detectAndClassify() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Capture image from camera
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // Detect faces with ML Kit
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        print('👤 No face detected');
        return DetectionResult.noFace();
      }

      // Get first detected face
      final face = faces.first;
      print('👤 Face detected! Confidence: ${face.headEulerAngleY}');

      // Crop face from image for classification
      final croppedFace = await _cropFaceFromImage(
        image.path,
        face.boundingBox,
      );

      // Classify gender and age
      final classification = await _classifier!.classify(croppedFace);

      return DetectionResult.detected(
        gender: classification['gender'],
        ageGroup: classification['age_group'],
        confidence: classification['confidence'],
      );
    } catch (e) {
      print('❌ Detection failed: $e');
      return DetectionResult.noFace();
    }
  }

  // Crop face region from image
  static Future<img.Image> _cropFaceFromImage(
    String imagePath,
    Rect boundingBox,
  ) async {
    try {
      // Read image file
      final imageFile = await img.decodeImageFile(imagePath);
      if (imageFile == null) {
        throw Exception('Failed to decode image');
      }

      // Add padding to bounding box
      final padding = 20;
      final x = (boundingBox.left - padding).clamp(0, imageFile.width).toInt();
      final y = (boundingBox.top - padding).clamp(0, imageFile.height).toInt();
      final width = (boundingBox.width + padding * 2)
          .clamp(0, imageFile.width - x)
          .toInt();
      final height = (boundingBox.height + padding * 2)
          .clamp(0, imageFile.height - y)
          .toInt();

      // Crop face region
      final cropped = img.copyCrop(
        imageFile,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      return cropped;
    } catch (e) {
      print('❌ Failed to crop face: $e');
      rethrow;
    }
  }

  // Quick face detection (without classification - faster)
  static Future<bool> hasface() async {
    if (!_isInitialized) await initialize();

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector!.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      print('❌ Quick detection failed: $e');
      return false;
    }
  }

  // Dispose
  static Future<void> dispose() async {
    await _faceDetector?.close();
    await _cameraController?.dispose();
    await _classifier?.dispose();
    _isInitialized = false;
    print('🔴 Face Detection Service disposed');
  }

  // Getters
  static bool get isInitialized => _isInitialized;
  static CameraController? get cameraController => _cameraController;
}
