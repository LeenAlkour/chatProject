import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Http {
  String Token="Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5YzgxZTJkMS1jMzFlLTQxNDMtYjgxNy0xMjQxYWU5YmJlYTIiLCJqdGkiOiI3MzdmY2QyMDc2ZmY0ODA4NGE3NGQ4OGRjNjUwM2U0Y2Q1YTEyNThlZjViNmUyMjBjNzhkYzdmNGIwM2M3Y2I1YmQ1MDNlODQxMmJhN2QwMyIsImlhdCI6MTcyMDg1NDc2Ny42ODA1MiwibmJmIjoxNzIwODU0NzY3LjY4MDUyMywiZXhwIjoxNzUyMzkwNzY3LjY2MTIwMiwic3ViIjoiNyIsInNjb3BlcyI6W119.d0XMp0RLCOCnk-Wa2DJaDrHOaHFZleCsqTjMmLYE9A4KBAsqkLblRUI646e8ldnY0whRDWWTgaoq9-cAziJEAGrNckvGk824QA9JIl3C6DVsa_7v4bo9Q20slrkC3QySRq8vznBcjUWttD1zRTL0FVlDtIXeXV8caKJy9JOqz-3Fob_nCC4WjMuSRjNsmO-yfR_RJ9qw0vjvLxyodDvSg0Nav-TNDebsHcxh2F5FubStIjWLv8hLoq5rzt5CrrmAO8wxamG6el1mdwBZDQ7ENHG1jdk2KpAe5f-3om2uUe2feMVI68dMuynRvag3DXWIpRMQ69bzz59C4LlaMnAF3TN0Q8knFdkR9bjuNIcWjdrAMZtmfDV1Rd6kWbcx-2-HOSTWyUyrrFye5H-5B0L4_Fs9w6pY1wX_T44Fv19A2RZtCy8E6X2Ebh2vYLo0Zw0dS8KogthiMtBTZLliHGht_UBt8lY_u87gR7ry2KEst-OuF4kiCOquuLKA4dTLMmsB9Z-mdao1MDI7TGJRDCKMLAB3-s0se4Dy0Igd0ZxNalVwC4hahTv9byv5igWUZcc2X_pgntgp1v18FpsK_PBd7DHjKyCOzc6cEbMjon7ahlR8vRaLLVLgXN7ja-BetjRk126ls2ZDPfyeXMxZBHcSi4STg6ekxgMfnaGWQakGc-Q";
  int id =7;
  String baseUrl = "http://192.168.1.7:8000/api/";
  Future<dynamic> post(String rout, var data) async {
    try {
      final response = await http
          .post(headers: {'Authorization': Token}, Uri.parse(baseUrl+rout), body: data);
      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        print("========================");
        return json.decode(response.body);
      } else {
        print(response.statusCode);
        throw Exception(
            'Failed to post data ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  Future<dynamic> get(String rout) async {
    try {
      final response =
          await http.get(headers: {'Authorization': Token}, Uri.parse(baseUrl+rout));
      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        return json.decode(response.body);
      } else {
        print(response.statusCode);
        throw Exception(
            'Failed to get data ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to get data: $e');
    }
  }

  Future<dynamic> postMultipart(String rout,var data) async {
    try {
      var headers = {
        'Authorization':'$Token'
       };
      var request = http.MultipartRequest(
          'POST', Uri.parse(baseUrl+rout));
      request.fields.addAll(data);

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.statusCode);
        print("==================");



      } else {
        print(response.reasonPhrase);
      }

  } catch (e) {
  print('Error: $e');
  throw Exception('Failed to get data: $e');
  }
  }
}
