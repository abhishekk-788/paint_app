import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class DrawingArea {

  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<DrawingArea> points = [];
  Color currentColor;
  double strokeWidth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentColor = Colors.black;
    strokeWidth = 2.0;
  }

  void changeColor(Color color) => setState(() => currentColor = color);


  @override
  Widget build(BuildContext context) {

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ]
              )
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.8,
                  height: height * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      )
                    ]
                  ),
                  child: GestureDetector(
                    onPanDown: (details) {
                      this.setState(() {
                        points.add(
                          DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..color = currentColor
                              ..strokeWidth = strokeWidth
                              ..isAntiAlias = true
                          )
                        );
                      });
                    },
                    onPanUpdate: (details) {
                      this.setState(() {
                        points.add(
                            DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..color = currentColor
                                  ..strokeWidth = strokeWidth
                                  ..isAntiAlias = true
                            )
                        );
                      });
                    },
                    onPanEnd: (details) {
                      this.setState(() {
                        points.add(null);
                      });
                    },

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: MyCustomPainter(points: points),

                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(Icons.color_lens),
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Color Chooser',
                                  ),
                                  content: SingleChildScrollView(
                                    child: BlockPicker(
                                      pickerColor: currentColor,
                                      onColorChanged: changeColor,
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        setState(() => currentColor = currentColor);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                      ),
                      Slider(
                        value: strokeWidth,
                        onChanged: (newStrokeWidth) {
                          setState(() {
                            strokeWidth = newStrokeWidth;
                          });
                        },
                        min: 1,
                        max: 7,
                        activeColor: currentColor,
                      ),
                      IconButton(
                        icon: Icon(Icons.layers_clear),
                        onPressed: (){
                          this.setState(() {
                            points.clear();
                          });
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {

  List <DrawingArea> points;
  Color color;
  double strokeWidth;

  MyCustomPainter({this.points, this.color, this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backGround = Paint();
    backGround.color = Colors.white;
    Rect rectangle = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rectangle, backGround);

    for(int x = 0; x < points.length - 1; x++) {
      if(points[x] != null && points[x+1] != null) {
        Paint paint = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x+1].point, paint);
      }
      else if(points[x] != null && points[x+1] == null) {
        Paint paint = points[x].areaPaint;
        canvas.drawPoints(PointMode.points, [points[x].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

