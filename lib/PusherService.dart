import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'Service/Http.dart';

class PusherService {
  Http httpRe = new Http();

  late PusherChannelsFlutter pusher;
  final String apiKey = "96d2e92039cae81ec5af";
  final String cluster = "us2";
  String authEndpoint = 'http://10.0.2.2:8000/api/broadcasting/auth';
  String Token =
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5YzYzOWE5Yy00MDViLTQ2YzgtODBhMi1lNTQwODE0MzdmYWIiLCJqdGkiOiJjNjNmYzY4MTc2NTNmMGM2OWVjZWU2Njk0ODEyZGQwMTk3ZDQ5MDJhMzUyYmFkMmJjMzVhZjE1OGJlOWUxZGI1NTRmZTI5Mzc5YjU1NDBhMCIsImlhdCI6MTcxOTUxNjQzMy4zNDA1MDMsIm5iZiI6MTcxOTUxNjQzMy4zNDA1MDcsImV4cCI6MTc1MTA1MjQzMy4xNjQxMjYsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.kfyyf2OQMmM_OFNnIja8DVz0tHOIOrkcOiykBF7Bm5oulRXkvGwAjAhKKKoxlfm4qW1RNX6oIXSaj2I2VzRDsZ91YBkzYr7EhyoN3h0G6x1ea7wtiY6f0sdRsX-te5-Vh4Kpairo6idOVb7Qf4-5Ti8XxM8Cp8uaAfHFqe1RBBOTkgTj3NQXWUVpXzK06hEZ3GNVXv-OMAYpXio0qDk0iAAGh9iqiJ2hSb90X6UCdjeEEaKk8-g0KaqVpAnw9-ZPLndkQKegq6IsB_I8KFiu3NjPwUOL7rtVazKgDCYhFmsHPvfGpkXfqBX7tkiQpnoYeCpPOjXGNGTiENT8J2ruO7ZVDh1D3anmYz-YfdsKtK-S8wKiFbyXHkU_1gYCxxmtYymCbNBpx7bt25BV583wgYSpbpYON0w5bLi00LskZjncqA0Y9yARLM5NFoECRcy6nMChx3QY7zGyDkteqC1uNI0jN4MbGl5emxs0ZUWn0RKZq7dkdCdU9VkUo5w_xJ5eEetlbFSQhfiX9wAL43x_-vUMjCf-U8CdLIntHVaFBpzy17-mpSF5n3ap_fSp78eIRX6oYK3mrc8FgEUWbxpHebhUGKIFTaNiIolJYO4yzDoYSYqJLpeVFK81QSoR-HubRm5jP6gUdowRHC4WOXV2ap-cGK6_d-6PpH9HcMxneIM";

  Function(dynamic)? onEventCallback;
  Future<void> initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher.init(
        apiKey: '96d2e92039cae81ec5af', // ضع App Key هنا
        cluster: 'us2', // ضع App Cluster هنا
        authEndpoint: 'http://10.0.2.2:8000/api/broadcasting/auth',
        onAuthorizer: (channelName, socketId, options) async {
          try {
            var headers = {
              'Content-Type': 'application/json',
              'Authorization': httpRe.Token
            };
            var request = http.Request('POST',
                Uri.parse('http://10.0.2.2:8000/api/broadcasting/auth'));
            request.body = json
                .encode({"socket_id": socketId, "channel_name": channelName});
            request.headers.addAll(headers);

            http.StreamedResponse response = await request.send();

            if (response.statusCode == 200) {
              print(response.statusCode);

              var responseBody = await response.stream.bytesToString();
              print(responseBody);
              return json.decode(responseBody);
            } else {
              throw Exception('Failed to authorize');
            }
          } catch (e) {
            print('Error: $e');
            throw Exception(': $e');
          }
        },
        onEvent: (event) {
          if (event.eventName == 'message.sent') {
            // print("Received event: ${event.data}");
            // print(event.data.runtimeType);
            // setState(() {
            //   messages.add(jsonDecode(event.data));
            // });
          }
          // scrollToBottom();
        },
      );
      await pusher.connect();
      await pusher.subscribe(channelName: 'private-chat.2',);

    } catch (e) {
      print("Pusher initialization error: $e");
    }
  }

  Future<void> subscribeToChannel(String channelName) async {
    try {
      await pusher.subscribe(channelName: channelName);
    } catch (e) {
      throw Exception('Error subscribing to channel: $e');
    }
  }

  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      await pusher.unsubscribe(channelName: channelName);
    } catch (e) {
      throw Exception('Error unsubscribing from channel: $e');
    }
  }

  Future<void> disconnectPusher() async {
    try {
      await pusher.disconnect();
    } catch (e) {
      throw Exception('Error disconnecting Pusher: $e');
    }
  }
}
