import 'package:flutter/material.dart';
import 'package:client/message_screen.dart';
import 'package:client/conversation_model.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

class UserHome extends StatelessWidget {
  UserHome({super.key, required this.username});

  final String username;
  List<Conversation> conversations = [];
  Conversation? selectedConversation = new Conversation("", "", "");

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
                        bool isGroupChat = data?[index].usernames?.length > 2;
                        int numPeople = 0;
                        for (int i = 0; i < data?[index].usernames.length; i++) {
                          var participantUsername = data?[index].usernames[i];
                          if (participantUsername != this.username) {
                            numPeople++;
                            s += participantUsername.toString() + " ";
                            if (isGroupChat && numPeople != data?[index].usernames.length - 1) {
                              s += "+ ";
                            }
                          }
                        }
                        return ListTile(
                          title: Text(s),
                          onTap: () {
                            selectedConversation = data?[index];
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MessageScreen(conversation: selectedConversation)),
                            );
                          },
                        );
                      }
                    ),
                  ),
                ),
                // Flexible(
                //   child: MessageScreen(conversation: selectedConversation)
                // )
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
