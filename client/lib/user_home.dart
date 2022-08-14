import 'package:flutter/material.dart';
import 'package:client/user_model.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

class Conversation {
  final id;
  final messageIds;
  final usernames;

  const Conversation(this.id, this.messageIds, this.usernames);
}

class Message {
  final id;
  final content;
  final sendTime;
  final senderUsername;

  const Message(this.id, this.content, this.sendTime, this.senderUsername);
}

class UserHome extends StatelessWidget {
  UserHome({super.key, required this.username});

  final String username;
  List<Conversation> conversations = [];
  List<Message> messages = [];

  Future<List<Conversation>> getConversations(String username) async {
    http.Response res = (await ApiService().getConversationIds(username));
    if (res.statusCode == 200) {
      var conversationIdsObj = json.decode(res.body);
      for (final conversationId in conversationIdsObj['conversation_ids']) {
        http.Response res2 = (await ApiService().getConversations(conversationId));
        var conversationJson = json.decode(res2.body);
        var conversation = new Conversation(conversationJson['id'], conversationJson['message_ids'], conversationJson['usernames']);
        conversations.add(conversation);
      }
      return conversations;
    }
    return [];
  }

  Future<List<Message>> getMessages(Conversation? conversation) async {
    if (conversation == null) {
      return messages;
    }
    for (final messageId in conversation.messageIds) {
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
        title: const Text('Messages'),
      ),
      body: FutureBuilder<List<Conversation>>(
        future:  getConversations(this.username),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Conversation>? data = snapshot.data;
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
                        String s = "";
                        for (var participantUsername in data?[index].usernames) {
                          if (participantUsername != this.username) {
                            s += participantUsername.toString() + " ";
                          }
                        }
                        return ListTile(
                          title: Text(s),
                          onTap: () => getMessages(data?[index]),
                        );
                      }
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: new ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: data?.length,
                      itemBuilder: (context, index) {
                        String s = "";
                        for (var participantUsername in data?[index].usernames) {
                          if (participantUsername != this.username) {
                            s += participantUsername.toString() + " ";
                          }
                        }
                        return ListTile(
                          title: Text(s),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserHome(username: this.username),
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),
                ),
              ],
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
