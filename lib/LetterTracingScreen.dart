import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'LetterController.dart';


class LetterTracingScreen extends StatelessWidget {
  final String letter;
  final LetterController controller = Get.put(LetterController());

  LetterTracingScreen({required this.letter});

  @override
  Widget build(BuildContext context) {
    controller.setReferencePoints(letter); // تعيين النقاط المرجعية بناءً على الحرف

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracing $letter'),
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPosition = box.globalToLocal(details.globalPosition);
            controller.addPoint(localPosition);
          },
          onPanEnd: (details) {
            bool isCorrect = controller.isTracingCorrect();
            String message = isCorrect ? 'Good Job!' : 'Try Again!';
            Get.snackbar('Result', message);
            controller.clearPoints();
          },
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: CustomPaint(
              painter: LetterPainter(controller.points, letter),
            ),
          ),
        ),
      ),
    );
  }
}

class LetterPainter extends CustomPainter {
  final List<Offset> points;
  final String letter;

  LetterPainter(this.points, this.letter);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (Offset point in points) {
      canvas.drawCircle(point, 5.0, paint);
    }

    // رسم الحرف المرجعي
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 200,
          color: Colors.grey.shade300,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 4, size.height / 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
