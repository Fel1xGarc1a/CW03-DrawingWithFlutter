import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DrawingApp(),
    );
  }
}

class DrawingApp extends StatefulWidget {
  @override
  _DrawingAppState createState() => _DrawingAppState();
}

class _DrawingAppState extends State<DrawingApp> {
  List<Shape> shapes = [];
  ShapeType selectedShape = ShapeType.circle;
  EmojiType selectedEmoji = EmojiType.partyHatSmiley; // Default is party hat smiley

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CW03 - Drawing with Flutter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Select Shape: "),
                DropdownButton<ShapeType>(
                  value: selectedShape,
                  onChanged: (ShapeType? newShape) {
                    setState(() {
                      selectedShape = newShape!;
                    });
                  },
                  items: ShapeType.values.map((ShapeType shape) {
                    return DropdownMenuItem<ShapeType>(
                      value: shape,
                      child: Text(shape.name.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Select Emoji: "),
                DropdownButton<EmojiType>(
                  value: selectedEmoji,
                  onChanged: (EmojiType? newEmoji) {
                    setState(() {
                      selectedEmoji = newEmoji!;
                    });
                  },
                  items: EmojiType.values.map((EmojiType emoji) {
                    return DropdownMenuItem<EmojiType>(
                      value: emoji,
                      child: Text(emoji.name.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                setState(() {
                  RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final localPosition =
                      renderBox.globalToLocal(details.localPosition);

                  if (selectedShape == ShapeType.emoji) {
                    shapes.add(Shape(localPosition, selectedShape,
                        emojiType: selectedEmoji));
                  } else {
                    shapes.add(Shape(localPosition, selectedShape));
                  }
                });
              },
              child: CustomPaint(
                painter: ShapePainter(shapes),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            shapes.clear();
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}

// Enum for shape types
enum ShapeType { circle, square, arc, emoji }

// Enum for different emojis
enum EmojiType { partyHatSmiley, heart }

extension ShapeTypeName on ShapeType {
  String get name {
    switch (this) {
      case ShapeType.circle:
        return "Circle";
      case ShapeType.square:
        return "Square";
      case ShapeType.arc:
        return "Arc";
      case ShapeType.emoji:
        return "Emoji";
    }
  }
}

extension EmojiTypeName on EmojiType {
  String get name {
    switch (this) {
      case EmojiType.partyHatSmiley:
        return "Party Hat Smiley";
      case EmojiType.heart:
        return "Heart";
    }
  }
}

// Class to store shape data
class Shape {
  Offset position;
  ShapeType type;
  EmojiType? emojiType;
  Shape(this.position, this.type, {this.emojiType});
}

// Painter class
class ShapePainter extends CustomPainter {
  final List<Shape> shapes;
  ShapePainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    for (Shape shape in shapes) {
      if (shape.type == ShapeType.circle) {
        paint.color = Colors.blue;
        canvas.drawCircle(shape.position, 40, paint);
      } else if (shape.type == ShapeType.square) {
        paint.color = Colors.green;
        canvas.drawRect(
            Rect.fromCenter(center: shape.position, width: 15, height: 15),
            paint);
      } else if (shape.type == ShapeType.arc) {
        paint.color = Colors.red;
        paint.style = PaintingStyle.fill;
        canvas.drawArc(
            Rect.fromCenter(center: shape.position, width: 30, height: 30),
            0,
            3.14,
            true,
            paint);
      } else if (shape.type == ShapeType.emoji) {
        if (shape.emojiType == EmojiType.partyHatSmiley) {
          _drawPartyHatSmiley(canvas, shape.position);
        } else if (shape.emojiType == EmojiType.heart) {
          _drawHeart(canvas, shape.position);
        }
      }
    }
  }

  // Function to draw a party hat smiley face
  void _drawPartyHatSmiley(Canvas canvas, Offset position) {
    Paint facePaint = Paint()..color = Colors.yellow;
    Paint eyePaint = Paint()..color = Colors.black;
    Paint mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    // Draw face
    canvas.drawCircle(position, 60, facePaint);

    // Draw eyes
    canvas.drawCircle(Offset(position.dx - 25, position.dy - 20), 5, eyePaint);
    canvas.drawCircle(Offset(position.dx + 25, position.dy - 20), 5, eyePaint);

    // Draw smile (arc)
    Path mouthPath = Path();
    mouthPath.moveTo(position.dx - 25, position.dy + 20);
    mouthPath.arcToPoint(Offset(position.dx + 25, position.dy + 20),
        radius: Radius.circular(15), clockwise: false);
    canvas.drawPath(mouthPath, mouthPaint);

    // Draw party hat
    Paint hatPaint = Paint()..color = Colors.blue;
    Path hatPath = Path();
    hatPath.moveTo(position.dx - 30, position.dy - 50); // Left point of hat
    hatPath.lineTo(position.dx, position.dy - 90); // Top point of hat
    hatPath.lineTo(position.dx + 30, position.dy - 50); // Right point of hat
    hatPath.close();
    canvas.drawPath(hatPath, hatPaint);

    // Draw hat decoration (a small circle on top)
    Paint decorationPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(position.dx, position.dy - 95), 5, decorationPaint);
  }

  // Function to draw a heart shape
  void _drawHeart(Canvas canvas, Offset position) {
    Paint heartPaint = Paint()..color = Colors.red;
    Path heartPath = Path();
    heartPath.moveTo(position.dx, position.dy + 20);
    heartPath.cubicTo(
        position.dx - 30, position.dy - 30, position.dx - 60, position.dy + 10, position.dx, position.dy + 60);
    heartPath.cubicTo(
        position.dx + 60, position.dy + 10, position.dx + 30, position.dy - 30, position.dx, position.dy + 20);
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
