import 'package:flutter/material.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:client/message_model.dart';
import 'package:client/conversation_model.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({super.key, this.conversation});

  final Conversation? conversation;
  List<Message> messages = [];

  Future<List<Message>> getMessages() async {
    for (final messageId in conversation?.messageIds) {
      http.Response res = (await ApiService().getMessage(messageId));
      if (res.statusCode == 200) {
        var messageJson = json.decode(res.body);
        var message = new Message(messageJson['id'], messageJson['content'], messageJson['sendTime'], messageJson['senderUsername']);
        messages.add(message);
      }
    }
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Screen'),
      ),
      body: FutureBuilder<List<Message>>(
        future: getMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Message>? data = snapshot.data;
            return Row(
              children: <Widget>[
                  //some widgets        
                Flexible(
                  child: SizedBox(
                    width: 200.0,
                    child: new ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: data?.length,
                      itemBuilder: (context, index) {
                        String s = data?[index].content;
                        return ListTile(
                          title: Text(s),
                        );
                      }
                    ),
                  ),
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
