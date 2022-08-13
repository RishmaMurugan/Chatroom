import 'package:flutter/material.dart';
import 'package:client/user_model.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;


class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  void initState() {
    super.initState();
    // _getData();
  }

  void createUser(String username, String password) async {
    http.Response res = (await ApiService().createUser(username, password));
  }

  void loginUser(String username, String password) async {
    http.Response res = (await ApiService().loginUser(username, password));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = new TextEditingController();
    TextEditingController pwController = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatroom Screen 2'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: pwController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            ElevatedButton(
                onPressed: () => createUser(usernameController.text, pwController.text),
                child: const Text('Sign Up'),
            ),
            ElevatedButton(
                onPressed: () => loginUser(usernameController.text, pwController.text),
                child: const Text('Login'),
            ),
          ],
        )
      )
    );
  }
}
