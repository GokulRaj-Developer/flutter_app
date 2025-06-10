import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../session_storage.dart';

class FaceValidationScreen extends StatefulWidget {
  const FaceValidationScreen({super.key});

  @override
  State<FaceValidationScreen> createState() => _FaceValidationScreenState();
}

class _FaceValidationScreenState extends State<FaceValidationScreen> {
  late CameraController _cameraController;
  bool _isInitialized = false;
  String _message = '';
  late String _storedImagePath;
  late String _firstName;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _storedImagePath = session.storedImagePath ?? '';
    _firstName = session.firstName ?? 'User';
  }



  Future<void> _validateFace() async {
  try {
    if (_storedImagePath.isEmpty) {
      setState(() {
        _message = 'Stored image not found. Please capture face again.';
      });
      return;
    }

    final liveImage = await _cameraController.takePicture();
    final storedImageFile = File(_storedImagePath);
    final liveImageFile = File(liveImage.path);

    final isMaskDetected = await _isWearingMaskOrHijab(liveImageFile);
    final isUniformValid = await _isWearingUniform(liveImageFile);
    final isFaceMatched = await _compareFaces(storedImageFile, liveImageFile);

    if (isMaskDetected) {
      setState(() {
        _message = 'Face covered with mask or hijab. Please remove and try again.';
      });
    } else if (!isUniformValid) {
      setState(() {
        _message = 'Uniform not detected. Please wear white, black or blue uniform.';
      });
    } else if (!isFaceMatched) {
      setState(() {
        _message = 'Face does not match stored image. Try again.';
      });
    } else {
      setState(() {
        _message = 'Hi $_firstName! face matched';
      });

      session.storedImagePath = null;
      session.firstName = null;

      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      Navigator.pushNamed(context, '/success', arguments: {'firstName': _firstName});
    }
  } catch (e) {
    setState(() {
      _message = 'Error: ${e.toString()}';
    });
  }
}


  Future<bool> _isWearingMaskOrHijab(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: true,
        enableLandmarks: true,
      ),
    );

    final List<Face> faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) return true; // No face = likely covered

    final face = faces.first;
    final landmarks = face.landmarks;

    final nose = landmarks[FaceLandmarkType.noseBase];
    final leftCheek = landmarks[FaceLandmarkType.leftCheek];
    final rightCheek = landmarks[FaceLandmarkType.rightCheek];

    // If nose or cheeks are missing → face may be covered
    return nose == null || leftCheek == null || rightCheek == null;
  }

  Future<bool> _isWearingUniform(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return false;

    int whiteCount = 0;
    int blueCount = 0;
    int blackCount = 0;
    int totalCount = 0;

    for (int y = image.height * 2 ~/ 3; y < image.height * 5 ~/ 6; y++) {
      for (int x = image.width ~/ 3; x < image.width * 2 ~/ 3; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        if (r > 200 && g > 200 && b > 200) whiteCount++;
        if (r < 100 && g < 100 && b > 150) blueCount++;
        if (r < 50 && g < 50 && b < 50) blackCount++;
        totalCount++;
      }
    }

    final whiteRatio = whiteCount / totalCount;
    final blueRatio = blueCount / totalCount;
    final blackRatio = blackCount / totalCount;

    return whiteRatio > 0.4 || blueRatio > 0.4 || blackRatio > 0.4;
  }

  Future<bool> _compareFaces(File storedImage, File liveImage) async {
  final detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: false,
      enableContours: false,
    ),
  );

  final storedInput = InputImage.fromFile(storedImage);
  final liveInput = InputImage.fromFile(liveImage);

  final storedFaces = await detector.processImage(storedInput);
  final liveFaces = await detector.processImage(liveInput);

  if (storedFaces.isEmpty || liveFaces.isEmpty) return false;

  // Crop face from images
  final storedBytes = await storedImage.readAsBytes();
  final liveBytes = await liveImage.readAsBytes();

  final storedImg = img.decodeImage(storedBytes);
  final liveImg = img.decodeImage(liveBytes);

  if (storedImg == null || liveImg == null) return false;

  final storedFace = storedFaces.first.boundingBox;
  final liveFace = liveFaces.first.boundingBox;


  final storedCrop = img.copyCrop(
  storedImg,
  x: storedFace.left.toInt(),
  y: storedFace.top.toInt(),
  width: storedFace.width.toInt(),
  height: storedFace.height.toInt(),
);

final liveCrop = img.copyCrop(
  liveImg,
  x: liveFace.left.toInt(),
  y: liveFace.top.toInt(),
  width: liveFace.width.toInt(),
  height: liveFace.height.toInt(),
);


  // Resize to same size
  final storedResized = img.copyResize(storedCrop, width: 100, height: 100);
  final liveResized = img.copyResize(liveCrop, width: 100, height: 100);

  // Compare using mean squared error
  double mse = 0;
  for (int y = 0; y < 100; y++) {
    for (int x = 0; x < 100; x++) {
      final p1 = storedResized.getPixel(x, y);
      final p2 = liveResized.getPixel(x, y);
      final dr = p1.r - p2.r;
      final dg = p1.g - p2.g;
      final db = p1.b - p2.b;
      mse += (dr * dr + dg * dg + db * db) / 3;
    }
  }
  mse = mse / (100 * 100);

  // Lower MSE = more similar. Tune threshold as needed (e.g., < 1000)
  return mse < 1000;
}


  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Validation")),
      body: _isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _validateFace,
                  child: const Text("Validate Face"),
                ),
                const SizedBox(height: 10),
                Text(
                  _message,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
