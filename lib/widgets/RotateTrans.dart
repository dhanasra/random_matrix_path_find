
import 'package:flutter/cupertino.dart';

class RotateTrans extends StatefulWidget {
  const RotateTrans({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key);

  final Widget child;
  final Animation animation;

  @override
  _RotateTransState createState() => _RotateTransState();
}

class _RotateTransState extends State<RotateTrans> with SingleTickerProviderStateMixin{


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: widget.animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.animation.value,
          child: Container(
            child: child,
          ),
        );
      },
    );
  }
}