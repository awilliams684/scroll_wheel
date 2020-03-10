import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

double _screenWidth;
double _screenHeight;

double _wheelPos = 0;

double _currTouchPos = 0;
double _startTouchPos = 0;
double _lastTouchPos = 0;
double _offsetTouchPos = 0;

double _lastPos = 0;

final double scaleFactor = 0.9;


class ScrollWheel extends StatefulWidget {
  ScrollWheel({
    Key key, 
  }) : super(key: key);
  @override
  _ScrollWheelState createState() => _ScrollWheelState();
}

class _ScrollWheelState extends State<ScrollWheel> {
  double _wheelThickness = 0;
  double _wheelRadius = 0;

  double _getTheta(double _x, double _y) {
    double _screenXCenter = _screenWidth / 2;
    double _screenYCenter = _screenHeight / 2;

    double _dx = _x - _screenXCenter;
    double _dy = _y - _screenYCenter;

    double _th = atan2(_dy, _dx);
    _th = _th + (90 * pi / 180);
    return _th;
  }

  double _radToDeg(radians) {
    double _deg = radians * 180 / pi;
    if (_deg < 0) {
      _deg += 360;
    }
    return _deg;
  }

  double _degToRad(deg) {
    return deg * pi / 180;
  }

  void _panHandler(DragUpdateDetails d) {
    _currTouchPos = _getTheta(d.globalPosition.dx, d.globalPosition.dy);

    _updateWheelPos(_degToRad((_radToDeg(_currTouchPos) - _offsetTouchPos)));

    if ((_radToDeg(_currTouchPos).roundToDouble() - _lastPos.roundToDouble())
            .abs() >
        15) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
      _lastPos = _radToDeg(_currTouchPos);
    }
  }

  void _updateWheelPos(double _pos) {
    setState(() {
      _wheelPos = _pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _wheelRadius = MediaQuery.of(context).orientation == Orientation.portrait
        ? (_screenWidth * scaleFactor) / 2
        : (_screenHeight * scaleFactor) / 2;
    double _wheelDia = _wheelRadius * 2;
    double _notches = (_wheelRadius * 0.25).roundToDouble();
    _wheelThickness = _wheelRadius * 0.3;

    return GestureDetector(
      onPanStart: (d) {
        _startTouchPos =
            _radToDeg(_getTheta(d.globalPosition.dx, d.globalPosition.dy));
        _offsetTouchPos = (_startTouchPos - _lastTouchPos);
      },
      onPanUpdate: _panHandler,
      onPanEnd: (d) {
        double _velocity = d.velocity.pixelsPerSecond.distance;
        if (_lastTouchPos < _radToDeg(_wheelPos)) {
          print("clockwise");
        } else {
          print("counterclockwise");
        }
        _lastTouchPos = _radToDeg(_wheelPos);
      },
      child: Container(
        alignment: Alignment.center,
        width: _wheelDia,
        height: _wheelDia,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Transform.rotate(
          angle: _wheelPos,
          child: CustomPaint(
            painter: new ScrollWheelPainter(
                _wheelRadius, _wheelThickness, _notches),
            willChange: false,
            isComplex: true,
          ),
        ),
      ),
    );
  }
}

class ScrollWheelPainter extends CustomPainter {
  double _whRad = 0;
  double _whThk = 0;
  double _notchCnt = 0;

  ScrollWheelPainter(this._whRad, this._whThk, this._notchCnt);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // calculate notch radians
    final double _notchDeg = (360 / _notchCnt);
    final double _notchRad = (_notchDeg * pi) / 180.0;

    // paint wheel background
    paint.color = Color(0xFF181818);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = _whThk;
    canvas.drawCircle(Offset(0, 0), _whRad - (_whThk / 2), paint);

    // paint wheel borders
    paint.color = Color(0xFF0d0d0d);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(0, 0), _whRad + 1, paint);
    canvas.drawCircle(Offset(0, 0), _whRad - _whThk, paint);

    paint.strokeCap = StrokeCap.round;

    for (int i = 0; i < _notchCnt; i++) {
      canvas.rotate(_notchRad);

      paint.color = Color(0xFF080808);
      paint.strokeWidth = 11.0;
      canvas.drawLine(
          Offset(0, (_whRad - _whThk) + 5), Offset(0, _whRad - 5), paint);

      paint.color = Color(0xFF202020);
      paint.strokeWidth = 7.0;
      canvas.drawLine(
          Offset(0, (_whRad - _whThk) + 6), Offset(0, _whRad - 6), paint);

      paint.color = Color(0xFF121212);
      paint.strokeWidth = 5.0;
      canvas.drawLine(
          Offset(0, (_whRad - _whThk) + 6), Offset(0, _whRad - 6), paint);
    }

    paint.color = Colors.white.withOpacity(0.2);
    paint.strokeWidth = 4.0;
    canvas.drawLine(
        Offset(0, (_whRad - _whThk) + 7), Offset(0, _whRad - 7), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
