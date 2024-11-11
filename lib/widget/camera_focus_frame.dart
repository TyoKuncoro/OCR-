import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

class CameraFocusFrame extends StatefulWidget {
  const CameraFocusFrame({super.key});

  @override
  State<CameraFocusFrame> createState() => _CameraFocusFrameState();
}

class _CameraFocusFrameState extends State<CameraFocusFrame> {
  Offset? offset;
  CancelableOperation<void>? _cancelableOperation;

  void move(Offset pos) {
    _cancelableOperation?.cancel();

    setState(() {
      offset = pos;
    });

    _cancelableOperation = CancelableOperation.fromFuture(
            Future.delayed(const Duration(seconds: 1)))
        .then(
      (p0) {
        setState(() {
          offset = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (details) {
          move(details.localPosition);
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: _Painter(offset),
        ));
  }
}

class _Painter extends CustomPainter {
  final Offset? position;
  late Paint _paint;
  final double _borderLineLength = 30;
  final Size _frameSize = const Size(150, 159);

  _Painter(this.position) {
    _paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (position == null) {
      return;
    }

    var r = Rect.fromCenter(
        center: position!, height: _frameSize.height, width: _frameSize.width);

    var path = Path();

    //top left border
    path.moveTo(r.left, r.top + _borderLineLength);
    path.lineTo(r.left, r.top);
    path.lineTo(r.left + _borderLineLength, r.top);
    canvas.drawPath(path, _paint);

    //top right border
    path.moveTo(r.right, r.top + _borderLineLength);
    path.lineTo(r.right, r.top);
    path.lineTo(r.right - _borderLineLength, r.top);
    canvas.drawPath(path, _paint);

    //bottom left border
    path.moveTo(r.left, r.bottom - _borderLineLength);
    path.lineTo(r.left, r.bottom);
    path.lineTo(r.left + _borderLineLength, r.bottom);
    canvas.drawPath(path, _paint);

    //bottom right border
    path.moveTo(r.right, r.bottom - _borderLineLength);
    path.lineTo(r.right, r.bottom);
    path.lineTo(r.right - _borderLineLength, r.bottom);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
