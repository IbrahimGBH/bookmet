import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con el Vendedor'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text('Pantalla de Chat en construcción 🚧'),
      ),
    );
  }
}