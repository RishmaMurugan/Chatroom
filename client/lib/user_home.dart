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
class UserHome extends StatelessWidget {
  UserHome({super.key, required this.username});

  final String username;
  List<Conversation> conversations = [];

  Future<List<Conversation>> getConversations(String username) async {
    http.Response res = (await ApiService().getConversationIds(username));
    if (res.statusCode == 200) {
      var conversationIdsObj = json.decode(res.body);
      for (final conversationId in conversationIdsObj['conversation_ids']) {
        http.Response res2 = (await ApiService().getConversations(conversationId));
        var conversationJson = json.decode(res2.body);
        var conversation = new Conversation(conversationJson['id'], conversationJson['message_ids'], conversationJson['usernames']);
        print(conversationJson['usernames']);
        conversations.add(conversation);
      }
      return conversations;
    }
    return [];
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
            return ListView.builder(
              itemCount: data?.length,
              itemBuilder: (context, index) {
                String s = "";
                for (var username in data?[index].usernames) {
                  s += username.toString() + " ";
                }
                return Text(s);
            });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        }
      )
    );
  }
}
