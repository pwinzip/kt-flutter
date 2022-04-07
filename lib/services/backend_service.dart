import 'dart:io';

import 'package:http/http.dart' as http;

// var API_URL = 'https://kt-laravel-backend.herokuapp.com/api/';
var apiURL = "http://127.0.0.1:8000/api/";

// Farmers
Future<http.Response> getPlantAmount(farmerid, String token) async {
  var url = Uri.parse(apiURL + 'amountplants/$farmerid');

  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });

  print(response.statusCode);
  print(response.body);

  return response;
}

Future<http.Response> getAllPlants(farmerid, String token) async {
  var url = Uri.parse(apiURL + 'allplants/$farmerid');

  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });

  return response;
}

Future<http.Response> saveFarmerPlant(json, farmerid, String token) async {
  var url = Uri.parse(apiURL + 'addplant/$farmerid');

  var response = await http.post(url, body: json, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

// Enterprise
Future<http.Response> getCountPlantFarmer(entid, String token) async {
  var url = Uri.parse(apiURL + 'allenterpriseplants/$entid');

  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

Future<http.Response> getSales(entid, String token) async {
  var url = Uri.parse(apiURL + 'sales/$entid');

  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

Future<http.Response> getMembers(entid, String token) async {
  var url = Uri.parse(apiURL + 'members/$entid');

  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

Future<http.Response> addSale(json, entid, String token) async {
  var url = Uri.parse(apiURL + 'addsales/$entid');

  var response = await http.post(url, body: json, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

// Admin
Future<http.Response> addEnterprise(json, String? token) async {
  var url = Uri.parse(apiURL + 'addenterprise');

  var response = await http.post(url, body: json, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

Future<http.Response> addFarmer(json, String? token) async {
  var url = Uri.parse(apiURL + 'addfarmer');

  var response = await http.post(url, body: json, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

Future<http.Response> getAmountMember(String? token) async {
  var url = Uri.parse(apiURL + 'countall');

  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
  return response;
}

Future<http.Response> getAllEnterprises(String? token) async {
  var url = Uri.parse(apiURL + 'enterprises');
  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });

  print(response.statusCode);
  return response;
}

Future<http.Response> getAllEnterpriseMembers(int? entid, String? token) async {
  var url = Uri.parse(apiURL + 'enterprisemembers/$entid');
  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });

  print(response.statusCode);
  return response;
}
