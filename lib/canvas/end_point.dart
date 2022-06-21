import 'dart:math';

import 'package:flutter/material.dart';

class EndPoint extends CustomPainter {

  EndPoint({required this.isJoined});
  final bool isJoined;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = isJoined ? Colors.green: Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    var dotPaint = Paint()
      ..color = isJoined ? Colors.green: Colors.red;
    Rect rect = Rect.fromCircle(center: Offset(size.width, 0), radius: size.height/2);
    canvas.drawCircle(Offset(size.width/2,size.height/2), size.height/4, paint);
    canvas.drawCircle(Offset(size.width/2,size.height/2), size.height/6, dotPaint);
    canvas.drawLine(Offset(size.width/2, size.height/2),Offset(size.width, size.height/2), paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}