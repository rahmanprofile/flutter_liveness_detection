import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liveness_detection/flutter_liveness_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestCameraPermission();
  runApp(const MyApp());
}

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (!status.isGranted) {
    runApp(const PermissionDeniedApp());
  }
}

class PermissionDeniedApp extends StatelessWidget {
  const PermissionDeniedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Permission Denied"),
        ),
        body: Center(
          child: AlertDialog(
            title: const Text("Permission Denied"),
            content: const Text("Camera access is required for verification."),
            actions: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text('Identify'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please click the button below to start verification',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),

            (imageFile != null) ?
            SizedBox(
                height: 200,width: 150,
                child: Image.file(imageFile!),
            ) :
            SizedBox(),


            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                foregroundColor: Colors.black,
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                final cameras = await availableCameras();
                if (cameras.isNotEmpty) {
                  final XFile? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlutterLivenessDetection()),
                  );

                  if (result != null) {
                    setState(() {
                      imageFile = File(result.path);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification Successful!')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera not active!')),
                  );
                }
              },

              // onPressed: () async {
              //   final cameras = await availableCameras();
              //   if (cameras.isNotEmpty) {
              //     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const FlutterLivenessDetection()));
              //     if (result == true) {
              //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification Successful!')));
              //     }
              //   } else {
              //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera not active!')));
              //   }
              // },

              child: const Text('Verify Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
