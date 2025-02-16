import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mediwise/Health%20Mobile%20App/utils/color.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final String apiKey =
      "AIzaSyAU2IgOs9oZackY49au2pCC61Wd4c87viE"; // Replace with actual API key

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech Status: $status"),
      onError: (errorNotification) => print("Speech Error: $errorNotification"),
    );

    if (!available) {
      print("Speech recognition is not available");
    }
  }

  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      print("Microphone permission denied");
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech Status: $status");
        if (status == "notListening") {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        print("Speech Error: $errorNotification");
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            print("Recognized: ${result.recognizedWords}");
          });
        },
        listenFor: const Duration(seconds: 10), // Max listening time
        pauseFor: const Duration(seconds: 2), // Stops after 2 sec of silence
        localeId: "en_US",
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      if (_controller.text.isNotEmpty) {
        sendMessage(_controller.text);
        _controller.clear();
      }
    });
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({"sender": "user", "text": message, "time": _getTime()});
    });

    String context = messages.map((msg) => msg['text']).join("\n");

    String prompt = '''
      You are a medical assistant bot. Answer only medical-related questions.
      Conversation history:
      $context
      User: $message
      Provide a relevant medical response.
    ''';

    final response = await http.post(
      Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final reply =
          responseData['candidates'][0]['content']['parts'][0]['text'];

      setState(() {
        messages.add({"sender": "bot", "text": reply, "time": _getTime()});
      });
    } else {
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "Error: Unable to connect.",
          "time": _getTime()
        });
      });
    }
  }

  String _getTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MediWise AI Chat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == "user";

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF1E88E5)
                              : const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['text']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          message['time']!,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 1)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16), // Better padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(
                    width: 10), // Spacing between text field and send button
                GestureDetector(
                  onTap: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10), // Adjusted padding
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
                const SizedBox(
                    width: 10), // Spacing between send button and mic button
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    padding: const EdgeInsets.all(10), // Adjusted padding
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
