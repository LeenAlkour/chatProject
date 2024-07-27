import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String imageUrl;
  final List<String> correctAnswer;
  final List<String> options;
  final String audioUrl;

  QuizScreen({
    required this.imageUrl,
    required this.correctAnswer,
    required this.options,
    required this.audioUrl,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<String?> userAnswer = [];
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    userAnswer = List<String?>.filled(widget.correctAnswer.length, null);
    audioPlayer = AudioPlayer();
  }

  void _playAudio() async {
        await audioPlayer.play(AssetSource("assets/1.mp3") );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'What animal is this',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),
        Image.asset(
          widget.imageUrl,
          height: 200,
        ),
        IconButton(
          icon: Icon(Icons.volume_up),
          onPressed: _playAudio,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: userAnswer
              .asMap()
              .entries
              .map((entry) => DragTarget<String>(
            onAccept: (data) {
              setState(() {
                userAnswer[entry.key] = data;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text(
                    entry.value ?? '',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ))
              .toList(),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            padding: EdgeInsets.all(20),
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              return Draggable<String>(
                data: widget.options[index],
                child: OptionTile(letter: widget.options[index]),
                feedback: Material(
                  color: Colors.transparent,
                  child: OptionTile(letter: widget.options[index]),
                ),
                childWhenDragging: OptionTile(letter: '', isDragging: true),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _checkAnswer,
            child: Text('NEXT'),
          ),
        ),
      ],
    );
  }

  void _checkAnswer() {
    if (widget.correctAnswer.equals(userAnswer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try Again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class OptionTile extends StatelessWidget {
  final String letter;
  final bool isDragging;

  OptionTile({required this.letter, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDragging ? Colors.grey[300] : Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}

extension ListEquality on List<String?> {
  bool equals(List<String?> other) {
    if (this.length != other.length) return false;
    for (int i = 0; i < this.length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}
