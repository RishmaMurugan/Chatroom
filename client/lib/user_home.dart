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
  String groupParticipants = "";

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
        MaterialPageRoute(builder: (context) => MessageScreen(conversation: this.selectedConversation, senderUsername: senderUsername, groupParticipants: groupParticipants)),
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
        title: const Text('Messages', style: TextStyle(fontSize: 25),),
      ),
      body: FutureBuilder<List<Conversation>>(
        future:  getConversations(widget.username),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Conversation>? data = snapshot.data;
            return Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Your Conversations:', style: TextStyle(fontSize: 20),),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: 300.0,
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
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: 
                                ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                                tileColor: Colors.teal[100],
                                title: Text(s),
                                onTap: () {
                                  selectedConversation = data?[index];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MessageScreen(conversation: selectedConversation, senderUsername: widget.username, groupParticipants: s)),
                                  );
                                },
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Start a new conversation!', style: TextStyle(fontSize: 20),),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 600.0,
                            child: new TextField(
                              controller: recipientsController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                labelText: 'Message Recipients',
                              ),
                            ),   
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 600.0,
                            child: new TextField(
                              controller: newMessageController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                labelText: 'Type your message here',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 600.0,
                            child: new ElevatedButton(
                              onPressed: () {
                                createConversation(widget.username, newMessageController.text, recipientsController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)
                                ),
                              ),
                              child: const Text('Send'),
                            ),
                          ),
                        ),
                      ]
                    ),
                  ]
                )                
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Container(
            width: MediaQuery.of(context).size.width, 
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                      ),
                    ]
                  )
                ]
              )              
          );
        }
      )
    );
  }
}
