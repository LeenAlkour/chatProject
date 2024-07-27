import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:testnoti/Inbox/InboxScreen.dart';
import 'Firebase/LocalNotification.dart';
import 'Firebase/NotificationIcon .dart';
import 'Firebase/firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  LocalNotification.showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  LocalNotification.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: InboxScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotification.showNotification(message);
      setState(() {
        _notificationCount++;
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // يمكنك التعامل مع النقر على الإشعار هنا
      print("loooooooooooooooooooooooooooooooooooooooooooooooooool");
    });
    _getToken();
  }

  var _fcmToken;
  void _getToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $_fcmToken");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Notification Demo"),
        actions: [
          NotificationIcon(notificationCount: _notificationCount),
        ],
      ),
      body: Center(
        child: Text("مرحبًا بكم في تطبيق الإشعارات!"),
      ),
    );
  }
}

//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// import 'Inbox/InboxScreen.dart';
//
// void main() {
//
//
//   runApp( const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       home:InboxScreen()
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: LetterSelectionScreen(),
//     );
//   }
// }
//
// class LetterSelectionScreen extends StatelessWidget {
//   final List<String> letters = List.generate(26, (index) => String.fromCharCode(index + 65));
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select a Letter'),
//       ),
//       body: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
//         itemCount: letters.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Get.to(() => LetterTracingScreen(letter: letters[index]));
//             },
//             child: Card(
//               child: Center(
//                 child: Text(
//                   letters[index],
//                   style: TextStyle(fontSize: 24),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class LetterTracingScreen extends StatelessWidget {
//   final String letter;
//   final LetterController controller = Get.put(LetterController());
//
//   LetterTracingScreen({required this.letter});
//
//   @override
//   Widget build(BuildContext context) {
//     controller.setReferencePoints(letter); // تعيين النقاط المرجعية بناءً على الحرف
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tracing $letter'),
//       ),
//       body: Center(
//         child: GestureDetector(
//           onPanUpdate: (details) {
//             RenderBox box = context.findRenderObject() as RenderBox;
//             Offset localPosition = box.globalToLocal(details.globalPosition);
//             controller.addPoint(localPosition);
//           },
//           onPanEnd: (details) {
//             bool isCorrect = controller.isTracingCorrect();
//             String message = isCorrect ? 'Good Job!' : 'Try Again!';
//             Get.snackbar('Result', message);
//             controller.clearPoints();
//           },
//           child: Container(
//             width: 300,
//             height: 300,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.black),
//             ),
//             child: Obx(
//                   () => CustomPaint(
//                 painter: LetterPainter(controller.points, letter),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class LetterPainter extends CustomPainter {
//   final List<Offset> points;
//   final String letter;
//
//   LetterPainter(this.points, this.letter);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 10.0;
//
//     for (Offset point in points) {
//       canvas.drawCircle(point, 5.0, paint);
//     }
//
//     // رسم الحرف المرجعي
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: letter,
//         style: TextStyle(
//           fontSize: 200,
//           color: Colors.grey.shade300,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout();
//     textPainter.paint(canvas, Offset(size.width / 4, size.height / 6));
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
// class LetterController extends GetxController {
//   // قائمة للتحكم في ألوان النقاط
//   var points = <Offset>[].obs;
//
//   // النقاط المرجعية
//   List<Offset> referencePoints = [];
//
//   void addPoint(Offset point) {
//     points.add(point);
//   }
//
//   void clearPoints() {
//     points.clear();
//   }
//
//   void setReferencePoints(String letter) {
//     // تعيين النقاط المرجعية بناءً على الحرف المختار
//     switch (letter) {
//       case 'A':
//         referencePoints = [
//           Offset(50, 200),
//           Offset(100, 50),
//           Offset(150, 200),
//           Offset(100, 150),
//         ];
//         break;
//       case 'B':
//       // إضافة النقاط المرجعية للحرف B
//         break;
//     // أضف بقية الحروف
//       default:
//         referencePoints = [];
//         break;
//     }
//   }
//
//   bool isTracingCorrect() {
//     if (points.isEmpty) return false;
//
//     int correctCount = 0;
//     for (Offset point in points) {
//       for (Offset refPoint in referencePoints) {
//         if ((point - refPoint).distance < 20) {
//           correctCount++;
//           break;
//         }
//       }
//     }
//
//     return correctCount >= referencePoints.length * 0.8;
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
//   String _log = 'output:\n';
//   final _apiKey = TextEditingController();
//   final _cluster = TextEditingController();
//   final _channelName = TextEditingController();
//   final _eventName = TextEditingController();
//   final _channelFormKey = GlobalKey<FormState>();
//   final _eventFormKey = GlobalKey<FormState>();
//   final _listViewController = ScrollController();
//   final _data = TextEditingController();
//
//   void log(String text) {
//     print("LOG: $text");
//     setState(() {
//       _log += text + "\n";
//       Timer(
//           const Duration(milliseconds: 100),
//               () => _listViewController
//               .jumpTo(_listViewController.position.maxScrollExtent));
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }
//
//   void onConnectPressed() async {
//     if (!_channelFormKey.currentState!.validate()) {
//       return;
//     }
//     // Remove keyboard
//     FocusScope.of(context).requestFocus(FocusNode());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("apiKey", _apiKey.text);
//     prefs.setString("cluster", _cluster.text);
//     prefs.setString("channelName", _channelName.text);
//
//     try {
//       await pusher.init(
//         apiKey: _apiKey.text,
//         cluster: _cluster.text,
//         onConnectionStateChange: onConnectionStateChange,
//         onError: onError,
//         onSubscriptionSucceeded: onSubscriptionSucceeded,
//         onEvent: onEvent,
//         onSubscriptionError: onSubscriptionError,
//         onDecryptionFailure: onDecryptionFailure,
//         onMemberAdded: onMemberAdded,
//         onMemberRemoved: onMemberRemoved,
//         onSubscriptionCount: onSubscriptionCount,
//         // authEndpoint: "<Your Authendpoint Url>",
//         // onAuthorizer: onAuthorizer
//       );
//       await pusher.subscribe(channelName: _channelName.text);
//       await pusher.connect();
//     } catch (e) {
//       log("ERROR: $e");
//     }
//   }
//
//   void onConnectionStateChange(dynamic currentState, dynamic previousState) {
//     log("Connection: $currentState");
//   }
//
//   void onError(String message, int? code, dynamic e) {
//     log("onError: $message code: $code exception: $e");
//   }
//
//   void onEvent(PusherEvent event) {
//     log("onEvent: $event");
//   }
//
//   void onSubscriptionSucceeded(String channelName, dynamic data) {
//     log("onSubscriptionSucceeded: $channelName data: $data");
//     final me = pusher.getChannel(channelName)?.me;
//     log("Me: $me");
//   }
//
//   void onSubscriptionError(String message, dynamic e) {
//     log("onSubscriptionError: $message Exception: $e");
//   }
//
//   void onDecryptionFailure(String event, String reason) {
//     log("onDecryptionFailure: $event reason: $reason");
//   }
//
//   void onMemberAdded(String channelName, PusherMember member) {
//     log("onMemberAdded: $channelName user: $member");
//   }
//
//   void onMemberRemoved(String channelName, PusherMember member) {
//     log("onMemberRemoved: $channelName user: $member");
//   }
//
//   void onSubscriptionCount(String channelName, int subscriptionCount) {
//     log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
//   }
//
//   dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
//     return {
//       "auth": "foo:bar",
//       "channel_data": '{"user_id": 1}',
//       "shared_secret": "foobar"
//     };
//   }
//
//   void onTriggerEventPressed() async {
//     var eventFormValidated = _eventFormKey.currentState!.validate();
//
//     if (!eventFormValidated) {
//       return;
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("eventName", _eventName.text);
//     prefs.setString("data", _data.text);
//     pusher.trigger(PusherEvent(
//         channelName: _channelName.text,
//         eventName: _eventName.text,
//         data: _data.text));
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _apiKey.text = prefs.getString("apiKey") ?? '';
//       _cluster.text = prefs.getString("cluster") ?? 'eu';
//       _channelName.text = prefs.getString("channelName") ?? 'my-channel';
//       _eventName.text = prefs.getString("eventName") ?? 'client-event';
//       _data.text = prefs.getString("data") ?? 'test';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(pusher.connectionState == 'DISCONNECTED'
//               ? 'Pusher Channels Example'
//               : _channelName.text),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListView(
//               controller: _listViewController,
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               children: <Widget>[
//                 if (pusher.connectionState != 'CONNECTED')
//                   Form(
//                       key: _channelFormKey,
//                       child: Column(children: <Widget>[
//                         TextFormField(
//                           controller: _apiKey,
//                           validator: (String? value) {
//                             return (value != null && value.isEmpty)
//                                 ? 'Please enter your API key.'
//                                 : null;
//                           },
//                           decoration:
//                           const InputDecoration(labelText: 'API Key'),
//                         ),
//                         TextFormField(
//                           controller: _cluster,
//                           validator: (String? value) {
//                             return (value != null && value.isEmpty)
//                                 ? 'Please enter your cluster.'
//                                 : null;
//                           },
//                           decoration: const InputDecoration(
//                             labelText: 'Cluster',
//                           ),
//                         ),
//                         TextFormField(
//                           controller: _channelName,
//                           validator: (String? value) {
//                             return (value != null && value.isEmpty)
//                                 ? 'Please enter your channel name.'
//                                 : null;
//                           },
//                           decoration: const InputDecoration(
//                             labelText: 'Channel',
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: onConnectPressed,
//                           child: const Text('Connect'),
//                         )
//                       ]))
//                 else
//                   Form(
//                     key: _eventFormKey,
//                     child: Column(children: <Widget>[
//                       ListView.builder(
//                           scrollDirection: Axis.vertical,
//                           shrinkWrap: true,
//                           itemCount: pusher
//                               .channels[_channelName.text]?.members.length,
//                           itemBuilder: (context, index) {
//                             final member = pusher
//                                 .channels[_channelName.text]!.members.values
//                                 .elementAt(index);
//
//                             return ListTile(
//                                 title: Text(member.userInfo.toString()),
//                                 subtitle: Text(member.userId));
//                           }),
//                       TextFormField(
//                         controller: _eventName,
//                         validator: (String? value) {
//                           return (value != null && value.isEmpty)
//                               ? 'Please enter your event name.'
//                               : null;
//                         },
//                         decoration: const InputDecoration(
//                           labelText: 'Event',
//                         ),
//                       ),
//                       TextFormField(
//                         controller: _data,
//                         decoration: const InputDecoration(
//                           labelText: 'Data',
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: onTriggerEventPressed,
//                         child: const Text('Trigger Event'),
//                       ),
//                     ]),
//                   ),
//                 SingleChildScrollView(
//                     scrollDirection: Axis.vertical, child: Text(_log)),
//               ]),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late PusherChannelsFlutter pusher;
//   List<String> messages = []; // قائمة لتخزين الرسائل المستلمة
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     initPusher();
//   }
//
//   Future<void> initPusher() async {
//     pusher = PusherChannelsFlutter.getInstance();
//
//     try {
//       await pusher.init(
//         apiKey: "46d740a1bd7fae16de73",
//         cluster: "eu",
//         onEvent: (event) {
//           setState(() {
//             messages.add(event.data); // إضافة الرسائل المستلمة إلى القائمة
//           });
//           print("Received event: ${event.data}");
//         },
//       );
//       await pusher.subscribe(channelName: "my-channel");
//     } catch (e) {
//       print("Error initializing Pusher: $e");
//     }
//   }
//
//   void sendMessage(String message) {
//     // هنا يمكن أن تضيف الكود اللازم لإرسال الرسالة عبر الـ Pusher
//     // هذا مجرد مثال على كيفية إرسال حدث عبر القناة
//     pusher.trigger(
//      PusherEvent(channelName:'my-channel' , eventName: 'my-event',data: message)
//     );
//     _controller.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Pusher Example'),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(messages[index]),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         labelText: 'Enter message',
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.send),
//                     onPressed: () {
//                       sendMessage(_controller.text);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
