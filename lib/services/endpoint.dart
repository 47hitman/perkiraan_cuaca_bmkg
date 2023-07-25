import 'dart:convert';

import 'package:http/http.dart' as http;

import 'custom_exception.dart';

class Endpoint {
  Endpoint._privateConstructor();
  String apiAddress = "https://ibnux.github.io/BMKG-importer/";
  static final Endpoint instance = Endpoint._privateConstructor();

//get kode wilayah
  Future kodewilayah() async {
    final http.Response response = await http.get(
      Uri.parse('${apiAddress}cuaca/wilayah.json'),
    );
    // print("code cuaca");
    // print(response.request);
    // print(response.body);
    // print(response);
    return _response(response);
  }

//data cuaca perwilayah
  Future cuacawilayah(int wilayahCode) async {
    final http.Response response = await http.get(
      Uri.parse('${apiAddress}cuaca/$wilayahCode.json'),
    );
    print("code cuaca");
    print(response.request);
    print(response.body);
    print(response);
    return _response(response);
  }
}

dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 204:
      return null;
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
      throw InvalidToken(response.body.toString());
    case 404:
      throw UnauthorizedException(response.body.toString());
    case 500:
      throw InvalidParameter(response.body.toString());
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode: ${response.statusCode}');
  }
}
