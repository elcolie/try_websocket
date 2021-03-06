import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final _channel =
      WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws/chat/cat/?token=8135bddc410bbf9eb8be7fb0ef347576de1b922e'));
  List<Widget> chatLog = [];

  @override
  Widget build(BuildContext context) {
    var dummy = StreamBuilder(
      stream: _channel.stream,
      builder: (context, snapshot) {
        var msg = Text(snapshot.hasData ? '${snapshot.data}' : '');
        chatLog.add(msg);
        var col = Column(
          children: chatLog,
        );
        return col;
      }
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            const SizedBox(height: 24),
            dummy,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(json.encode({'message': _controller.text}));
      _controller.text = '';
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
