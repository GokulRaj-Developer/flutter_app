import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../session_storage.dart'; 

class FacialCaptureScreen extends StatefulWidget {
  const FacialCaptureScreen({super.key});

  @override
  State<FacialCaptureScreen> createState() => _FacialCaptureScreenState();
}

class _FacialCaptureScreenState extends State<FacialCaptureScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  String _message = '';
  late String _firstName = 'User';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['firstName'] != null) {
      _firstName = args['firstName'];
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[1], ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _captureAndDetectFace() async {
    try {
      final image = await _cameraController.takePicture();
      final savedImage = await _saveImageLocally(File(image.path));
      final faceDetected = await _detectFace(savedImage);

      if (faceDetected) {
        session.storedImagePath = savedImage.path;
        session.firstName = _firstName;

        setState(() {
          _message = "Face detected. Proceeding...";
        });

        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

        Navigator.pushNamed(context, '/face_validation');
      } else {
        setState(() {
          _message = "No face detected. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: ${e.toString()}";
      });
    }
  }

  Future<File> _saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final savedImage = await image.copy('${directory.path}/$filename');
    return savedImage;
  }

  Future<bool> _detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
    final List<Face> faces = await faceDetector.processImage(inputImage);
    return faces.isNotEmpty;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Face")),
      body: _isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _captureAndDetectFace,
                  child: const Text("Capture Face"),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_message, style: const TextStyle(color: Colors.red)),
                  )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
