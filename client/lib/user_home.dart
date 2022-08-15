import 'package:flutter/material.dart';
import 'package:client/message_screen.dart';
import 'package:client/conversation_model.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';


class UserHome extends StatefulWidget {
  final String username;
  const UserHome({Key? key, required this.username}) : super(key: key);

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<Conversation> conversations = [];
  Conversation? selectedConversation = new Conversation("", "", "");

  @override
  void initState() {
    super.initState();
  }

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

  void createConversation(String senderUsername, String content, String usernamesString) async {
    http.Response res = (await ApiService().createConversation(senderUsername, content, usernamesString));
    if (res.statusCode == 200) {
      var conversationId = json.decode(res.body);
      http.Response res2 = (await ApiService().getConversations(conversationId));
      var conversationJson = json.decode(res2.body);
      var conversation = new Conversation(conversationJson['id'], conversationJson['message_ids'], conversationJson['usernames']);
      selectedConversation = conversation; 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessageScreen(conversation: this.selectedConversation, senderUsername: senderUsername)),
      );
    } 
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = new TextEditingController();
    TextEditingController newMessageController = new TextEditingController();
    TextEditingController recipientsController = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: FutureBuilder<List<Conversation>>(
        future:  getConversations(widget.username),
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
                          if (participantUsername != widget.username) {
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
                              MaterialPageRoute(builder: (context) => MessageScreen(conversation: selectedConversation, senderUsername: widget.username)),
                            );
                          },
                        );
                      }
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: newMessageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type your message here',
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: recipientsController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Create a new conversation with...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    createConversation(widget.username, newMessageController.text, recipientsController.text);
                  },
                  child: const Text('Send'),
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
