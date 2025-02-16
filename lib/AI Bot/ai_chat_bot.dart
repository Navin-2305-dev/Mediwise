import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:http/http.dart' as http;
import 'package:mediwise/Health%20Mobile%20App/utils/color.dart';
import 'package:animate_do/animate_do.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FileChatScreen extends StatefulWidget {
  const FileChatScreen({super.key});

  @override
  _FileChatScreenState createState() => _FileChatScreenState();
}

class _FileChatScreenState extends State<FileChatScreen> {
  String extractedText = "No text extracted yet";
  PlatformFile? pickedFile;
  String responseMessage = '';
  bool isLoading = false;
  bool isPdf = false;
  final promptController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
        isPdf = pickedFile!.extension == 'pdf';
        extractedText = isPdf ? "Extracting text..." : "Image selected.";
      });

      if (isPdf && pickedFile!.path != null) {
        await readPdfText(pickedFile!.path!);
      }
    }
  }

  Future<void> readPdfText(String filePath) async {
    try {
      String text = await ReadPdfText.getPDFtext(filePath);
      setState(() {
        extractedText = text.isNotEmpty ? text : "No text found in the PDF.";
      });
    } catch (e) {
      setState(() {
        extractedText = "Error reading PDF file.";
      });
    }
  }

  Future<void> generateResponse(String query) async {
    if (pickedFile == null) {
      setState(() => responseMessage = 'No file selected.');
      return;
    }

    setState(() {
      isLoading = true;
      responseMessage = '';
    });

    try {
      final Uri apiUrl = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyAU2IgOs9oZackY49au2pCC61Wd4c87viE",
      );

      final requestPayload = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    isPdf
                        ? "The user uploaded a PDF. Here is the extracted content:\n\n$extractedText\n\nNow answer the user's query: '$query'."
                        : "${promptController.text}. You are a strict medical AI assistant. You should analyze the given image and respond only if it is related to the medical field. If the image is unrelated to medicine, reply strictly with: 'I am a medical bot and cannot process non-medical images.'",
              },
              if (!isPdf && pickedFile!.bytes != null)
                {
                  "inlineData": {
                    "mimeType": "image/${pickedFile!.extension}",
                    "data": base64.encode(pickedFile!.bytes!),
                  },
                },
            ],
          },
        ],
      };

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          responseMessage =
              result['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
              'No response received';
        });
      } else {
        setState(() {
          responseMessage = 'Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Request Failed: ${e.toString()}';
      });
    }

    setState(() => isLoading = false);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            promptController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      if (promptController.text.isNotEmpty) {
        // sendMessage(promptController.text);
        promptController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "File Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInDown(
              child: GestureDetector(
                onTap: pickFile,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, size: 80, color: kPrimaryColor),
                        SizedBox(height: 10),
                        Text(
                          "Tap to Upload PDF or Image",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (pickedFile != null)
                      ZoomIn(
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Uploaded File: ${pickedFile!.name}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                isPdf
                                    ? Container(
                                      height: 150,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          extractedText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    : pickedFile!.bytes != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        pickedFile!.bytes!,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Text("Error loading image."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: promptController,
                      decoration: InputDecoration(
                        hintText: 'Enter a query',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => generateResponse(promptController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      child: const Text(
                        "Ask Question",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    ElevatedButton(
                      onPressed:
                          () => _isListening ? _stopListening : _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),
                    if (isLoading) const CircularProgressIndicator(),
                    if (!isLoading && responseMessage.isNotEmpty)
                      FadeIn(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            responseMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}