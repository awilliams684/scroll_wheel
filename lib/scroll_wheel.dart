import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

GlobalKey scrollWheelKey = GlobalKey();

double _wheelPos = 0;

double _currTouchPos = 0;
double _startTouchPos = 0;
double _lastTouchPos = 0;
double _offsetTouchPos = 0;

double _lastPos = 0;

final double scaleFactor = 0.9;

class ScrollWheel extends StatefulWidget {
  final double diameter;

  ScrollWheel({
    Key key,
    this.diameter,
  }) : super(key: key);

  @override
  _ScrollWheelState createState() => _ScrollWheelState();
}

class _ScrollWheelState extends State<ScrollWheel> {
  double _wheelThickness = 0;
  double _wheelRadius = 0;

  double _wheelCenterX = 0;
  double _wheelCenterY = 0;

  double _getTheta(double _x, double _y) {
    double _dx = _x - _wheelCenterX;
    double _dy = _y - _wheelCenterY;

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

  void _startPan(DragStartDetails d) {
    final RenderBox _scrollwheelRender =
        scrollWheelKey.currentContext.findRenderObject();
    final _positionScrollWheel = _scrollwheelRender.localToGlobal(Offset.zero);

    _wheelCenterX = _positionScrollWheel.dx + _wheelRadius;
    _wheelCenterY = _positionScrollWheel.dy + _wheelRadius;

    _startTouchPos =
        _radToDeg(_getTheta(d.globalPosition.dx, d.globalPosition.dy));
    _offsetTouchPos = (_startTouchPos - _lastTouchPos);
  }

  void _panUpdate(DragUpdateDetails d) {
    _currTouchPos = _getTheta(d.globalPosition.dx, d.globalPosition.dy);

    print(_radToDeg(_currTouchPos));

    _updateWheelPos(_degToRad((_radToDeg(_currTouchPos) - _offsetTouchPos)));

    if ((_radToDeg(_currTouchPos).roundToDouble() - _lastPos.roundToDouble())
            .abs() >
        15) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
      _lastPos = _radToDeg(_currTouchPos);
    }
  }

  void _endPan(DragEndDetails d) {
    double _velocity = d.velocity.pixelsPerSecond.distance;
    if (_lastTouchPos < _radToDeg(_wheelPos)) {
      print("clockwise");
    } else {
      print("counterclockwise");
    }
    _lastTouchPos = _radToDeg(_wheelPos);
  }

  void _updateWheelPos(double _pos) {
    setState(() {
      _wheelPos = _pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _wheelDia = widget.diameter;
    _wheelRadius = _wheelDia / 2;
    double _notches = (_wheelRadius * 0.25).roundToDouble();
    _wheelThickness = _wheelRadius * 0.25;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Outside outer border
        Container(
          width: _wheelDia,
          height: _wheelDia,
          decoration: BoxDecoration(
            color: Color(0xFF333333),
            shape: BoxShape.circle,
            border: Border.all(width: 0.5, color: Colors.black),
            boxShadow: [
              // Upper shadow light
              BoxShadow(
                color: Color(0xFF666666).withOpacity(0.5),
                blurRadius: 10.0,
                spreadRadius: 5.0,
                offset: Offset(0.0, -5.0),
              ),
              // Lower shadow dark
              BoxShadow(
                color: Color(0xFF000000).withOpacity(0.8),
                blurRadius: 10.0,
                spreadRadius: 5.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
          ),
        ),

        // Scroll wheel painter
        GestureDetector(
          onPanStart: _startPan,
          onPanUpdate: _panUpdate,
          onPanEnd: _endPan,
          child: Container(
            alignment: Alignment.center,
            width: _wheelDia * 0.95,
            height: _wheelDia * 0.95,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: _wheelPos,
              child: CustomPaint(
                painter: new ScrollWheelPainter(
                    _wheelRadius * 0.95, _wheelThickness, _notches),
                willChange: false,
                isComplex: true,
              ),
            ),
          ),
        ),

        Container(
          alignment: Alignment.center,
          width: _wheelDia * 0.65,
          height: _wheelDia * 0.65,
          decoration: BoxDecoration(
            color: Color(0xFF303030),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF202020),
                blurRadius: 2.0,
                spreadRadius: 6.0,
                offset: Offset(0.0, -2.0),
              ),
              BoxShadow(
                color: Color(0xFF252525),
                blurRadius: 2.0,
                spreadRadius: 6.0,
                offset: Offset(0.0, 2.0),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: _wheelDia * 0.6,
          height: _wheelDia * 0.6,
          decoration: BoxDecoration(
            color: Color(0xFF202020),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF000000),
                blurRadius: 10.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
          ),
        ),
      ],
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
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(Offset(0, 0), _whRad, paint);
    canvas.drawCircle(Offset(0, 0), _whRad - _whThk, paint);

    paint.strokeCap = StrokeCap.round;

    double _line0Stroke = 10.0;
    double _line0Y0 = ((_whRad - _whThk) + _line0Stroke / 2) + 2;
    double _line0Y1 = (_whRad - _line0Stroke / 2) - 2;

    double _line1Stroke = 6.0;
    double _line1Y0 = ((_whRad - _whThk) + _line1Stroke / 2) + 3;
    double _line1Y1 = (_whRad - _line1Stroke / 2) - 3;

    double _line2Stroke = 4.0;
    double _line2Y0 = ((_whRad - _whThk) + _line2Stroke / 2) + 5;
    double _line2Y1 = (_whRad - _line2Stroke / 2) - 5;

    for (int i = 0; i < _notchCnt; i++) {
      canvas.rotate(_notchRad);

      paint.color = Color(0xFF000000);

      paint.strokeWidth = _line0Stroke;
      canvas.drawLine(Offset(0, _line0Y0), Offset(0, _line0Y1), paint);

      paint.color = Color(0xFF1a1a1a);
      paint.strokeWidth = _line1Stroke;
      canvas.drawLine(Offset(0, _line1Y0), Offset(0, _line1Y1), paint);

      paint.color = Color(0xFF202020);
      paint.strokeWidth = _line2Stroke;
      canvas.drawLine(Offset(0, _line2Y0), Offset(0, _line2Y1), paint);
    }
    canvas.rotate(pi);
    paint.color = Colors.white30;
    paint.strokeWidth = 3.0;
    canvas.drawLine(Offset(0, _line2Y0), Offset(0, _line2Y1), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
