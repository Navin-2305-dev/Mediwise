import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mediwise/Health%20Mobile%20App/login%20page/Screen/login.dart';

class ChatPage extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const ChatPage({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty && currentUser != null) {
      String messageText = _messageController.text.trim();
      _messageController.clear();

      Timestamp timestamp = Timestamp.now();

      await _firestore.collection('chats').add({
        'senderId': currentUser!.uid,
        'recipientId': widget.recipientId,
        'message': messageText,
        'timestamp': timestamp,
        'lastMessageTime': timestamp,
      });

      List<String> sortedIds = [currentUser!.uid, widget.recipientId]..sort();
      String chatId = sortedIds.join('_');

      await _firestore.collection('user_chats').doc(chatId).set({
        'lastMessage': messageText,
        'lastMessageTime': timestamp,
        'users': [currentUser!.uid, widget.recipientId],
      }, SetOptions(merge: true));
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      if (_messageController.text.isNotEmpty) {
        _sendMessage();
        _messageController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.recipientName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .where(Filter.or(
                      Filter.and(
                        Filter('senderId', isEqualTo: currentUser!.uid),
                        Filter('recipientId', isEqualTo: widget.recipientId),
                      ),
                      Filter.and(
                        Filter('senderId', isEqualTo: widget.recipientId),
                        Filter('recipientId', isEqualTo: currentUser!.uid),
                      ),
                    ))
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var messageData =
                          messages[index].data() as Map<String, dynamic>;
                      var message = messageData['message'];
                      var timestamp = messageData['timestamp']?.toDate();
                      var senderId = messageData['senderId'];

                      bool isSender = senderId == currentUser!.uid;
                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSender ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                timestamp != null
                                    ? '${timestamp.hour}:${timestamp.minute}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                  IconButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
