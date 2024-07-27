import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LetterController extends GetxController {
  // قائمة للتحكم في ألوان النقاط
  var points = <Offset>[].obs;

  // النقاط المرجعية
  List<Offset> referencePoints = [];

  void addPoint(Offset point) {
    points.add(point);
  }

  void clearPoints() {
    points.clear();
  }

  void setReferencePoints(String letter) {
    // تعيين النقاط المرجعية بناءً على الحرف المختار
    switch (letter) {
      case 'A':
        referencePoints = [
          Offset(50, 200),
          Offset(100, 50),
          Offset(150, 200),
          Offset(100, 150),
        ];
        break;
      case 'B':
      // إضافة النقاط المرجعية للحرف B
        break;
    // أضف بقية الحروف
      default:
        referencePoints = [];
        break;
    }
  }

  bool isTracingCorrect() {
    if (points.isEmpty) return false;

    int correctCount = 0;
    for (Offset point in points) {
      for (Offset refPoint in referencePoints) {
        if ((point - refPoint).distance < 20) {
          correctCount++;
          break;
        }
      }
    }

    return correctCount >= referencePoints.length * 0.8;
  }
}
