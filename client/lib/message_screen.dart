import 'package:flutter/material.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:client/message_model.dart';
import 'package:client/conversation_model.dart';

class MessageScreen extends StatefulWidget {
  final Conversation? conversation;
  final String senderUsername;
  const MessageScreen({Key? key, this.conversation, required this.senderUsername}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<Message>> getMessages() async {
    if (messages.length == 0) {
      for (final messageId in widget.conversation?.messageIds) {
        http.Response res = (await ApiService().getMessage(messageId));
        if (res.statusCode == 200) {
          var messageJson = json.decode(res.body);
          var message = new Message(messageJson['id'], messageJson['content'], messageJson['sendTime'], messageJson['senderUsername']);
          messages.add(message);
        }
      }
    }
    return messages;
  }

  void sendMessage(String senderUsername, String conversationId, String content) async {
    http.Response res = (await ApiService().sendMessage(senderUsername, conversationId, content));
    if (res.statusCode == 200) {
      var messageId = json.decode(res.body);
      var message = new Message(messageId, content, DateTime.now(), senderUsername);
      setState((){
        messages.add(message);
      });
    } 
    else  {
      print('Error.');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = new TextEditingController();
    ScrollController _scrollController = new ScrollController();
    print("here");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Screen'),
      ),
      body: FutureBuilder<List<Message>>(
        future: getMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Message>? data = snapshot.data;
            return Column(
              children: <Widget>[
                  //some widgets        
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: 0.85,
                    child: new ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      scrollDirection: Axis.vertical,
                      itemCount: data?.length,
                      itemBuilder: (context, index) {
                        String sender = data?[index].senderUsername ;
                        String content = data?[index].content ;
                        return ListTile(
                          title: Text(sender + ": " + content),
                        );
                      }
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Send a message',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        sendMessage(widget.senderUsername, widget.conversation?.id, messageController.text);
                        // _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                      },
                      child: const Text('Send'),
                    ),
                  ]
                )
              ]
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        }
      )
    );
  }
}
