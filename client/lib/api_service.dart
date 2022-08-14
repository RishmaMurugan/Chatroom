import 'dart:developer';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:client/constants.dart';
import 'package:client/user_model.dart';

class ApiService {
  Future<http.Response> createUser(String username, String password) {
    return http.post(
        Uri.parse('http://127.0.0.1:5000/user'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
            'username': username,
            'password': password
        }),
    );
}
Future<http.Response> loginUser(String username, String password) {
    return http.patch(
        Uri.parse('http://127.0.0.1:5000/user'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
            'username': username,
            'password': password
        }),
    );
}
Future<http.Response> getConversationIds(String username) {
    return http.get(
        Uri.parse('http://127.0.0.1:5000/user?username=$username'),
    );
}
Future<http.Response> getConversations(String id) {
    return http.get(
        Uri.parse('http://127.0.0.1:5000/conversation?id=$id'),
    );
}
}