import 'dart:developer';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:client/constants.dart';
import 'package:client/user_model.dart';

class ApiService {
  Future<http.Response> createUser(String name, String password) {
    return http.post(
        Uri.parse('http://127.0.0.1:5000/user'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
            'username': name,
            'password': password
        }),
    );
}
Future<http.Response> loginUser(String name, String password) {
    return http.patch(
        Uri.parse('http://127.0.0.1:5000/user'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
            'username': name,
            'password': password
        }),
    );
}

}