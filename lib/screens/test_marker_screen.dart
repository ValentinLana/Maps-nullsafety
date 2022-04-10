import 'package:flutter/material.dart';
import 'package:maps/markers/end_Marker.dart';
import 'package:maps/markers/start_marker.dart';

class TestMarkerScreen extends StatelessWidget {
  const TestMarkerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.red,
          width: 350,
          height: 150,
          child: CustomPaint(
            painter: EndMarkerPainter(
              destination: 'Mi casa',
              kilometres: 50
            ),
          ),
        ),
      )
    );
  }
}