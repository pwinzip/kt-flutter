import 'dart:convert';
import 'dart:io';

import 'backend_service.dart';
import 'package:http/http.dart' as http;

Future<http.Response> login(String telephone, String password) async {
  var json = jsonEncode({
    "tel": telephone,
    "password": password,
  });
  var url = Uri.parse(apiURL + "login");

  var response = await http.post(url,
      body: json, headers: {HttpHeaders.contentTypeHeader: 'application/json'});

  return response;
}

Future<http.Response> logout(String token) async {
  var url = Uri.parse(apiURL + 'logout');
  var response = await http.post(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });

  return response;
}
