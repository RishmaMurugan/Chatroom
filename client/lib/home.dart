import 'package:flutter/material.dart';
import 'package:client/user_home.dart';
import 'package:client/api_service.dart';
import 'package:http/http.dart' as http;


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _username = "";
  @override
  void initState() {
    super.initState();
  }

  void createUser(String username, String password) async {
    http.Response res = (await ApiService().createUser(username, password));
    if (res.statusCode == 200) {
        _showSnackBar('Welcome!');
        setState(() {
            _username = username;
        });
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserHome()));
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserHome(username: username)),
        );
    } 
    else if (res.statusCode == 409) {
        _showSnackBar('Username already taken.');
    }
  }

  void loginUser(String username, String password) async {
    http.Response res = (await ApiService().loginUser(username, password));
    if (res.statusCode == 200) {
        _showSnackBar('Welcome!');
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserHome(username: username)),
        );
    } 
    else {
        _showSnackBar('Invalid login credentials.');
    }
  }

  void _showSnackBar(String msg) {
    final snackBar = SnackBar(
        content: Text(msg),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = new TextEditingController();
    TextEditingController pwController = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nimble Chatroom'),
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
                onPressed: () {
                    createUser(usernameController.text, pwController.text);
                },
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
