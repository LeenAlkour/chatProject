import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:testnoti/Inbox/InboxController.dart';
import 'package:testnoti/Inbox/InboxScreen.dart';
import 'package:testnoti/PusherService.dart';

import 'Service/Http.dart';

class ScreenChatApp extends StatefulWidget {
  int chatId;
  String userName;
  int contactId;
  ScreenChatApp(
      {super.key,
      required this.chatId,
      required this.userName,
      required String image,
      required this.contactId});

  @override
  _ScreenChatAppState createState() => _ScreenChatAppState();
}

class _ScreenChatAppState extends State<ScreenChatApp> {
  dynamic messages = [].obs;
  var isMeList = {}.obs;
  final ScrollController _scrollController = ScrollController();
  late PusherChannelsFlutter pusher;
  final TextEditingController _controller = TextEditingController();
  Http httpReq = Http();
  PusherService pu = new PusherService();
  bool isMe = false;
  bool isSelectionMode = false;
  var selectedMessagesId = [].obs;
  static const Color Turquoise = Color(0xFF67BDA4); // #67bda4
  static const Color Web = Color(0xFF15CAE0); // #15cae0
  static const Color DarkGreen = Color(0xFF80AF00); // #80af00
  static const Color Orange = Color(0xFFFFAF00); // #ffaf00
  static const Color Webl = Color(0xFF804277); // #804277
  InboxController controller = Get.put(InboxController());
  @override
  void initState() {
    super.initState();
    if (widget.chatId != 0) {
      getMessages();
      initPusher(widget.chatId);
    }
  }

  Future<void> initPusher(var chatId) async {
    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher.init(
        apiKey: '96d2e92039cae81ec5af', // ضع App Key هنا
        cluster: 'us2', // ضع App Cluster هنا
        authEndpoint: '${httpReq.baseUrl}broadcasting/auth',
        onAuthorizer: (channelName, socketId, options) async {
          try {
            var headers = {
              'Content-Type': 'application/json',
              'Authorization': httpReq.Token
            };
            var request = http.Request('POST',
                Uri.parse('${httpReq.baseUrl}broadcasting/auth'));
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
            print("Received event: ${event.data}");
            print(event.data.runtimeType);
            setState(() {
              messages.add(jsonDecode(event.data));
            });
          }
          // scrollToBottom();
        },
      );
      await pusher.connect();
      await pusher.subscribe(channelName: 'private-chat.${widget.chatId}');
    } catch (e) {
      print("Pusher initialization error: $e");
    }
  }

  Future<void> getMessages() async {
    dynamic response;
    response =
        await httpReq.post("displayMessages", {'chat_id': "${widget.chatId}"});
    if (response.isEmpty) {
      messages.value = [];
    } else {
      messages.value = response as List;
    }
    // scrollToBottom();
  }

  void _onMessageLongPress(int index, int id, bool isMe) {
    setState(() {
      isSelectionMode = true;
      selectedMessagesId.add(id);
      isMeList[id] = isMe;
    });
  }

  void _onMessageTap(int index, int id) {
    if (isSelectionMode) {
      setState(() {
        if (selectedMessagesId.contains(id)) {
          selectedMessagesId.remove(id);
          isMeList.remove(id);
          if (selectedMessagesId.isEmpty) {
            isSelectionMode = false;
          }
        } else {
          selectedMessagesId.add(id);
          isMeList[id] = isMe;
        }
      });
    }
  }

  void _showDeleteOptions(Map isMeList) {
    print(isMeList);
    if (isMeList.containsValue(false)) {
      Get.bottomSheet(
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'حذف الرسالة؟',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text('إلغاء'),
                    onPressed: () {
                      selectedMessagesId.clear();
                      isMeList.clear();
                      isSelectionMode = false;
                      Get.back(); // إغلاق الحوار
                    },
                  ),
                  TextButton(
                    child: Text('الحذف لدي'),
                    onPressed: () {
                      _deleteMessagesForMe();
                      Get.back(); // إغلاق الحوار
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      Get.bottomSheet(
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'حذف الرسالة؟',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text('إلغاء'),
                    onPressed: () {
                      selectedMessagesId.clear();
                      isMeList.clear();
                      isSelectionMode = false;
                      Get.back(); // إغلاق الحوار
                    },
                  ),
                  TextButton(
                    child: Text('الحذف لدى الجميع'),
                    onPressed: () {
                      _deleteMessagesForEveryone();
                      Get.back(); // إغلاق الحوار
                    },
                  ),
                  TextButton(
                    child: Text('الحذف لدي'),
                    onPressed: () {
                      _deleteMessagesForMe();
                      Get.back(); // إغلاق الحوار
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  void _deleteMessagesForMe() {
    setState(() {
      var mapped = Map.fromEntries(selectedMessagesId.asMap().entries.map(
          (entry) =>
              MapEntry('message ids[${entry.key}]', entry.value.toString())));
      print(mapped);
      httpReq.postMultipart("deleteMessagesForMe", mapped);
      getMessages();
      selectedMessagesId.clear();
      isMeList.clear();
      isSelectionMode = false;
    });
  }

  void _deleteMessagesForEveryone() {
    setState(() {
      var mapped = Map.fromEntries(selectedMessagesId.asMap().entries.map(
          (entry) => MapEntry('ids[${entry.key}]', entry.value.toString())));
      print(mapped);
      httpReq.postMultipart("deleteMessages", mapped);
      getMessages();
      selectedMessagesId.clear();
      isMeList.clear();
      isSelectionMode = false;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedMessagesId.clear();
      isSelectionMode = false;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // معالجة الصورة هنا
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      // معالجة الملف هنا
    }
  }

  Future<void> send(String message) async {
    messages.add(await httpReq.post("sendMessage",
        {'chat_id': widget.chatId.toString(), 'message': message}));
  }

  Future<void> chatCreat(String message) async {
    messages = await httpReq.post("createChat",
        {'receiver_id': widget.contactId.toString(), 'message': message});
    widget.chatId = messages['chat_id'];
    initPusher(widget.chatId);
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      if (widget.chatId == 0) {
        await chatCreat(_controller.text);
        _controller.clear();
      } else {
        send(_controller.text);
        _controller.clear();
      }

      getMessages();
    }
  }

  // void scrollToBottom() {
  //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  // }

  @override
  void dispose() {
    if (widget.chatId != 0) {
      pusher.unsubscribe(channelName: 'private-chat.${widget.chatId}');
      pusher.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context as BuildContext);
    var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;
    // مقاسات العناصر باستخدام MediaQuery
    var avatarRadius = screenHeight * 0.03;
    var messageFontSize = screenHeight * 0.02;
    var messagePadding = screenHeight * 0.015;
    Future<bool> _onWillPop(BuildContext context) async {
      controller.getChats().then((result) {
        Get.back();
      }).catchError((error) {
        print("errrrrrrrrrrrrrrrrrrrrrrrrrrore");
      });
      return true;
    }

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              controller.getChats().then((result) {
                Get.back();
              }).catchError((error) {
                print("errrrrrrrrrrrrrrrrrrrrrrrrrrore");
              });
            },
          ),
          elevation: 4.0,
          title: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: AssetImage('assets/ppppppppppppppppppppp.jpg'),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(widget.userName,
                  style: TextStyle(fontSize: messageFontSize * 1.2)),
            ],
          ),
          actions: [
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteOptions(isMeList);
                },
              ),
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSelection,
              ),
          ],
        ),
        body: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              messages != []
                  ? Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          if (message['sender_id'] == httpReq.id) {
                            isMe = true;
                          } else {
                            isMe = false;
                          }
                          bool isSelected =
                              selectedMessagesId.contains(message['id']);

                          return GestureDetector(
                            onLongPress: () =>
                                _onMessageLongPress(index, message['id'], isMe),
                            onTap: () => _onMessageTap(index, message['id']),
                            child: Container(
                              width: double.infinity,
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (message['message'] != null)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isMe
                                                  ? Web.withOpacity(0.8)
                                                  : Web.withOpacity(0.8),
                                              borderRadius: isMe
                                                  ? const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(25),
                                                      bottomLeft:
                                                          Radius.circular(25),
                                                      topRight:
                                                          Radius.circular(25))
                                                  : const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(25),
                                                      bottomRight:
                                                          Radius.circular(25),
                                                      topRight:
                                                          Radius.circular(25)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width *
                                                        0.7, // حدد العرض الأقصى للنص
                                                  ),
                                                  child: Text(
                                                    message['message'],
                                                    style: TextStyle(
                                                      fontSize:
                                                          messageFontSize *
                                                              0.95,
                                                      color: isMe
                                                          ? Colors.white
                                                          : Colors.white,
                                                    ),
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      message['sent_in_time']
                                                          .substring(0, 5),
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10),
                                                    ),
                                                    SizedBox(
                                                        width: screenWidth *
                                                            0.005),
                                                    if (isMe) ...[
                                                      if (message['status'] ==
                                                          "sent")
                                                        Icon(
                                                          Icons.done,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                                      if (message['status'] ==
                                                          "read")
                                                        Icon(
                                                          Icons.done_all,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (message['image'] != null)
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7),
                                          child: Image.file(message['image']),
                                        ),
                                      if (message['file'] != null)
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? Colors.blue[100]
                                                : Colors.grey[300],
                                            borderRadius: isMe
                                                ? const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(25),
                                                    bottomRight:
                                                        Radius.circular(25),
                                                    topRight:
                                                        Radius.circular(25))
                                                : const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(25),
                                                    bottomRight:
                                                        Radius.circular(25),
                                                    bottomLeft:
                                                        Radius.circular(25)),
                                          ),
                                          child: Text(
                                            'File: ${message['file'].path.split('/').last}',
                                            style: TextStyle(
                                                color: isMe
                                                    ? Colors.black
                                                    : Colors.black),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(child: Text("sendMessage")),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Web,
                      child: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white, size: 30),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
