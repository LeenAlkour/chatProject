import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testnoti/ScreenChatApp.dart';
import '../Service/Http.dart';
import 'InboxController.dart';
import 'InboxItem.dart';

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isSelectionMode = false;
  var selectedMessagesId = [].obs;

  @override
  void initState() {
    controller.getChats();
    super.initState();
  }

  Http httpReq = Http();
  InboxController controller = Get.put(InboxController());
  void _onChatLongPress(int index, var chatId) {
    setState(() {
      isSelectionMode = true;
      selectedMessagesId.add(chatId);
    });
  }

  void _onChatTap(int index, String userName, int id, var contactId) {
    if (isSelectionMode) {
      setState(() {
        if (selectedMessagesId.contains(id)) {
          selectedMessagesId.remove(id);

          if (selectedMessagesId.isEmpty) {
            isSelectionMode = false;
          }
        } else {
          selectedMessagesId.add(id);
        }
      });
    } else {
      if (controller.isSearchMode.value) {
        controller.toggleSearchMode();
        controller.chatsSearch.clear();
      }
      Get.to(
          popGesture: false,
          curve: Curves.easeIn,
          ScreenChatApp(
            chatId: id,
            userName: userName,
            image: 'assets/ppppppppppppppppppppp.jpg',
            contactId: contactId,
          ));
    }
  }

  void _deleteSelectedChats() {
    setState(() {
      var mapped = Map.fromEntries(selectedMessagesId.asMap().entries.map(
          (entry) =>
              MapEntry('chat_ids[${entry.key}]', entry.value.toString())));
      print(mapped);
      httpReq.postMultipart("deleteChats", mapped);
      controller.getChats();
      selectedMessagesId.clear();
      isSelectionMode = false;
    });
    print(selectedMessagesId);
  }

  void _clearSelection() {
    setState(() {
      selectedMessagesId.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    var screenWidth = media.size.width;

    return Obx(() => Scaffold(
        appBar: AppBar(
          title:
              controller.isSearchMode.value ? SizedBox.shrink() : Text('Inbox'),
          actions: [
            controller.isSearchMode.value
                ? Padding(
                    padding: const EdgeInsets.only(right: 18.0, top: 8),
                    child: Container(
                      width: screenWidth * 0.925,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            controller.getSearchChats(val);
                          } else {
                            controller.chatsSearch.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel_outlined,
                                color: Colors.black54),
                            onPressed: () async {
                              controller.toggleSearchMode();
                              controller.chatsSearch.clear();
                            },
                          ),
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      controller.toggleSearchMode();
                    },
                  ),
            if (isSelectionMode == true &&
                controller.isSearchMode.value == false)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _deleteSelectedChats,
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSelection,
                  ),
                ],
              )
          ],
        ),
        body: controller.isSearchMode.value
            ? ListView.builder(
                itemCount: controller.chatsSearch.length,
                itemBuilder: (context, index) {
                  final chat = controller.chatsSearch[index];
                  var chatId;
                  String time =
                      chat['time'] != null ? chat['time'].substring(0, 5) : " ";
                  if (chat['last message info '] == null) {
                    chatId = 0;
                  } else {
                    chatId = chat['last message info ']['chat id'];
                  }
                  if (chat == {}) {
                    return Center(child: const Text("لايوجد اشخاص بهذا الاسم"));
                  } else {
                    return InboxItem(
                      name: chat['contact info']['contact name'] ?? "",
                      lastMessage:
                          chat['last message info ']?['last message'] ?? "",
                      time: time,
                      unreadCount:
                          chat['last message info ']?['unreadCount'] ?? 0,
                      imageUrl: chat['imageUrl'] ??
                          'assets/ppppppppppppppppppppp.jpg',
                      isSelected: chat['isSelected'] ?? false,
                      onTap: () => _onChatTap(
                          index,
                          chat['contact info']['contact name'],
                          chatId,
                          chat['contact info']['contact id']),
                      screenWidth: screenWidth,
                      onLongPress: () {},
                      status: chat['last message info ']?['status'] ?? " ",
                    );
                  }
                },
              )
            : ListView.builder(
                itemCount: controller.chats.length,
                itemBuilder: (context, index) {
                  final chat = controller.chats[index];
                  bool isSelected =
                      selectedMessagesId.contains(chat['chat id']);
                  String time =
                      chat['time'] != null ? chat['time'].substring(0, 5) : " ";
                  if (chat == {}) {
                    return Center(child: const Text("لايوجد محادثات"));
                  } else {
                    return Column(
                      children: [
                        InboxItem(
                          name: chat['contact name'] ?? " ",
                          lastMessage: chat['last message'] ?? " ",
                          time: time,
                          unreadCount: chat['unreadCount'] ?? 0,
                          imageUrl: chat['imageUrl'] ??
                              'assets/ppppppppppppppppppppp.jpg',
                          isSelected: isSelected,
                          onLongPress: () =>
                              _onChatLongPress(index, chat['chat id']),
                          onTap: () => _onChatTap(index, chat['contact name'],
                              chat['chat id'], chat["contact id"]),
                          screenWidth: screenWidth,
                          status: chat['status'] ?? " ",
                        ),
                      ],
                    );
                  }
                })));
  }
}
