import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const Duration _timeout = Duration(seconds: 10);

  static Future<dynamic> _request(String method, Uri uri, {Object? body}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    try {
      final request = http.Request(method, uri);
      request.headers.addAll(headers);
      if(body != null) request.body = jsonEncode(body);

      final streamResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamResponse);

      return _parseResponse(response);
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'server taking too long';
    } catch(e) {
      throw 'Unexpected error: $e';
    }
  }

  static dynamic _parseResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if(response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      //specific error status codes
      final message = body is Map ? body['error'] :response.reasonPhrase;
      throw 'Error ${response.statusCode}: $message';
    }
  }

  static Future<dynamic> get(Uri uri) => _request('GET', uri);
  static Future<dynamic> post(Uri uri, Object body) => _request('POST', uri, body: body);
  static Future<dynamic> patch(Uri uri, Object body) => _request('PATCH', uri, body: body);
  static Future<dynamic> delete(Uri uri) => _request('DELETE', uri);

}
