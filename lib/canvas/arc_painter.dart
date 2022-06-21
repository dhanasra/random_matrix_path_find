import 'dart:math';

import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {

  ArcPainter({
    required this.isJoined,
    required this.joins
  });
  final bool isJoined;
  final int joins;

  @override
  void paint(Canvas canvas, Size size) {

    print(isJoined);

    var paint = Paint()
      ..color = isJoined ? Colors.green: Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    Rect rect = Rect.fromCircle(center: Offset(size.width, size.height), radius: size.height/2);
    Rect rect2 = Rect.fromCircle(center: Offset(0, size.height), radius: size.height/2);
    Rect rect3 = Rect.fromCircle(center: const Offset(0, 0), radius: size.height/2);
    Rect rect4 = Rect.fromCircle(center: Offset(size.width, 0), radius: size.height/2);

    if(joins==5) {
      canvas.drawLine(
          Offset(0, size.height / 2), Offset(size.width, size.height / 2),
          paint);
    }else{

      canvas.drawArc(rect, pi, pi/2, false, paint);
      if(joins>2) canvas.drawArc(rect2, 0, -pi/2, false, paint);
      if(joins>3) canvas.drawArc(rect3, 0, pi/2, false, paint);
      if(joins>=4) canvas.drawArc(rect4, pi, -pi/2, false, paint);
    }


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}