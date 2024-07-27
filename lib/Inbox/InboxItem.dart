import 'package:flutter/material.dart';

class InboxItem extends StatelessWidget {

  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String imageUrl;
  final bool isSelected;
  final String status;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  InboxItem({super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.imageUrl,
    this.isSelected = false,
    required this.status,
    required this.onLongPress,
    required this.onTap,
    required double screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(imageUrl),
              ),
              title: Text(name,style: TextStyle(fontWeight: FontWeight.w400),overflow: TextOverflow.ellipsis,),
              subtitle: Text(lastMessage,style: TextStyle(fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(time),
                  if (unreadCount > 0)
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if ( status=="sent")
                    Icon(
                      Icons.done,
                      size: 17,
                      color: Colors.grey,
                    ),
                  if ( status=="read")
                    Icon(
                      Icons.done_all,
                      size: 17,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          Divider(endIndent: 10,thickness: 0.4,indent: 10,height: 20.0
            ,)
        ],
      ),
    );
  }
}
