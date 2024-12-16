import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'openai.dart';

class ChatPage extends StatefulWidget {
  final OpenAI openAI;

  ChatPage({required this.openAI});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    _firestore.collection('chatHistory').orderBy('timestamp').snapshots().listen((snapshot) {
      setState(() {
        _messages = snapshot.docs.map((doc) {
          return {
            "role": doc["role"] as String,
            "content": doc["content"] as String,
          };
        }).toList();
      });
    });
  }

  Future<void> _saveMessage(String role, String content) async {
    await _firestore.collection('chatHistory').add({
      "role": role,
      "content": content,
      "timestamp": FieldValue.serverTimestamp(),
    });
    print('Message saved: $role - $content'); // Debug statement
  }

  void _sendMessage() async {
    String question = _controller.text;
    if (question.isNotEmpty) {
      setState(() {
        _messages.add({"role": "user", "content": question});
        _isLoading = true;
      });
      _controller.clear();
      _saveMessage("user", question);

      String? answer = await widget.openAI.answer(question);
      setState(() {
        _messages.add({"role": "assistant", "content": answer ?? 'No response from API'});
        _isLoading = false;
      });
      _saveMessage("assistant", answer ?? 'No response from API');
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message['content']!,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with Counselor')),
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            if (_isLoading) CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask a question',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text('Send'),
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