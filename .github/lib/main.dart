import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Оцифровка Паспорта',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _status = "Выберите файл паспорта или скриншот из Галереи";
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  Future<void> _pickAndScanFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      setState(() => _status = "Распознавание текста...");

      final inputImage = InputImage.fromFilePath(path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.cyrillic);
      final recognizedText = await textRecognizer.processImage(inputImage);

      String text = recognizedText.text;
      textRecognizer.close();

      final seriesMatch = RegExp(r'\b(\d{2}\s?\d{2}\s?\d{6})\b').firstMatch(text);
      if (seriesMatch != null) {
        _seriesController.text = seriesMatch.group(1)!;
      }

      final codeMatch = RegExp(r'\b(\d{3}-\d{3})\b').firstMatch(text);
      if (codeMatch != null) {
        _codeController.text = codeMatch.group(1)!;
      }

      setState(() => _status = "Данные считаны! Проверьте и дополните поля.");
    }
  }

  @style
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оцифровка паспорта')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickAndScanFile,
              icon: const Icon(Icons.photo_library),
              label: const Text('Выбрать из Галереи'),
            ),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: _seriesController,
              decoration: const InputDecoration(labelText: 'Серия и номер паспорта'),
            ),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Код подразделения'),
            ),
          ],
        ),
      ),
    );
  }
}
