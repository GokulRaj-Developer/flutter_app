import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceValidationScreen extends StatefulWidget {
  const FaceValidationScreen({super.key});

  @override
  State<FaceValidationScreen> createState() => _FaceValidationScreenState();
}

class _FaceValidationScreenState extends State<FaceValidationScreen> {
  late CameraController _cameraController;
  bool _isInitialized = false;
  //String? _storedImagePath;
  String _message = '';
  late String _storedImagePath;
  late String _firstName = 'User';

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

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final args = ModalRoute.of(context)?.settings.arguments;
  //   if (args is String) {
  //     _storedImagePath = args;
  //   }
  // }
  @override
  void didChangeDependencies() {
   super.didChangeDependencies();
   final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
     _storedImagePath = args['imagePath'];
     _firstName = args['firstName'] ?? 'User';
    }
  }


  Future<void> _validateFace() async {
    try {
      final liveImage = await _cameraController.takePicture();
      final storedImageFile = File(_storedImagePath);  //_storedImagePath!

      final isLiveFace = await _detectFace(File(liveImage.path));
      final isStoredFace = await _detectFace(storedImageFile);

      // if (isLiveFace && isStoredFace) {
      //   setState(() {
      //     _message = 'Hi Gokul';
      //   });

      //   await Future.delayed(const Duration(seconds: 1));
      //   if (!mounted) return;

      //   Navigator.pushNamed(context, '/success');
      // } 
      if (isLiveFace && isStoredFace) {
        setState(() {
         _message = 'Hi $_firstName';
        });

       await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

         Navigator.pushNamed(
          context,
          '/success',
          arguments: {
          'firstName': _firstName,
          },
          );

      }else {
        setState(() {
          _message = 'Face mismatch or not detected. Try again.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  Future<bool> _detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: true,
        enableLandmarks: true,
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
      appBar: AppBar(title: const Text("Face Validation")),
      body: _isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
                ),
                ElevatedButton(
                  onPressed: _validateFace,
                  child: const Text("Validate Face"),
                ),
                const SizedBox(height: 10),
                Text(_message, style: const TextStyle(color: Colors.green)),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
