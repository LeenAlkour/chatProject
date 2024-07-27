import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ColorGame extends StatefulWidget {
  // const ColorGame({super.key});

  @override
  State<ColorGame> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {
  final Map<String, bool> score = {};
  final Map choices1 = {
    '🍏': Colors.green,
    '🍋': Colors.yellow,
    '🍅': Colors.red,
    '🍇': Colors.purple,
    '🥥': Colors.brown,
    '🥕': Colors.orange,
  };
  final Map choices = {
    'أ': Container(child: Text("أرنب",style: TextStyle(fontSize: 40),),),
    'ب': Container(child: Text("بطة",style: TextStyle(fontSize: 40),),),
    'ت': Container(child: Text("تمساح",style: TextStyle(fontSize: 40),),),
    'ث': Container(child: Text("ثور",style: TextStyle(fontSize: 40),),),
    'ج': Container(child: Text("جاجة",style: TextStyle(fontSize: 40),),),
    'ح': Container(child: Text("حصان",style: TextStyle(fontSize: 40),),),
  };


  int seed = 0;
  AudioCache _audioController = AudioCache();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Scor ${score.length}/6"), backgroundColor: Colors.pink),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            score.clear();
            seed++;
          });
        },
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: choices.keys.map((emoji) {
              return Draggable<String>(
                child: Emoji(
                  emoji: score[emoji] == true ? '✔️' : emoji,
                ),
                feedback: Emoji(
                  emoji: emoji,
                ),
                childWhenDragging: Emoji(
                  emoji: '🌱',
                ),
                data: emoji,
              );
            }).toList(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                choices.keys.map((emoji) => buildDragTarget(emoji)).toList()
                  ..shuffle(Random(seed)),
          )
        ],
      ),
    );

  }

  Widget buildDragTarget(String emoji) {
    return DragTarget<String>(
      builder: (BuildContext context, List<String?> incoming, List<dynamic> rejectedData) {
        if (score[emoji] == true) {
          return Container(
            child: Text('Correct!'),
            alignment: Alignment.center,
            height: 80,
            width: 120,
            color: Colors.green, // تغيير اللون للتأكيد على الإجابة الصحيحة
          );
        } else {
          return Container(
            child: choices[emoji], // تأكد من أن choices[emoji] يُرجع قيمة لون صالحة
            height: 80,
            width: 120,

          );
        }
      },
      onWillAccept: (data) => data == emoji, // استخدام بسيط لـ onWillAccept
      onAccept: (data) {
        setState(() {
          score[emoji] = true;
        });
        // استخدم حزمة audio لتشغيل صوت إذا لزم الأمر
        // _audioController.play('true.mp3');
      },
      onLeave: (data) {
        // اختياري: إضافة ردود فعل عندما يترك البيانات الهدف
      },
    );
  }


}

class Emoji extends StatelessWidget {
  Emoji({required this.emoji}) : super();
  final String emoji;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        height: 80,
        padding: EdgeInsets.all(10),
        child: Text(
          emoji,
          style: TextStyle(color: Colors.black, fontSize:40),
        ),
      ),
    );
  }
}
