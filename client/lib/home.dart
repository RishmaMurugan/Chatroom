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
        title: const Text('NimbleChat', style: TextStyle(fontSize: 25),),
      ),
      body: 
        Container(
            width: MediaQuery.of(context).size.width, 
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Welcome to NimbleChat!', style: TextStyle(fontSize: 35),),
                    ),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: 
                            FractionallySizedBox(
                                widthFactor: 0.5,
                                child: new TextField(
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                        labelText: 'Username',
                                    ),
                                ),
                            ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: 
                            FractionallySizedBox(
                                widthFactor: 0.5,
                                child: new  TextField(
                                    controller: pwController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                        labelText: 'Password',
                                    ),
                                ),
                            ),
                    ),
                    Row (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child:
                                    ElevatedButton(
                                        onPressed: () => loginUser(usernameController.text, pwController.text),
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0)
                                            ),
                                        ),
                                        child: Text(
                                            "Login",
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                        ),
                                    ),
                            ),
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child:
                                    ElevatedButton(
                                        onPressed: () {createUser(usernameController.text, pwController.text);},
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0)
                                            ),
                                        ),
                                        child: Text(
                                            "Sign up",
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                        ),
                                    ),
                            ),
                        ]
                    )
                ],
            )
        )
      );
  }
}
