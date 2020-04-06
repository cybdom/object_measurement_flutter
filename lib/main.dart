import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const A4Height = 11.6929;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageRectScreen(),
    );
  }
}

class ImageRectScreen extends StatefulWidget {
  @override
  _ImageRectScreenState createState() => _ImageRectScreenState();
}

class _ImageRectScreenState extends State<ImageRectScreen> {
  Rect _rect, _objectRect, _referenceRect;
  Offset _start, _finish;
  PageController _pageViewController = PageController();
  Future<File> _image;
  @override
  void initState() {
    super.initState();
    _image = _getImage();
  }

  Future<File> _getImage() async {
    return await ImagePicker.pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (context, _) => Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: FutureBuilder<File>(
                      future: _image,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CustomPaint(
                            child: Image.file(
                              snapshot.data,
                            ),
                            foregroundPainter: MyRectPainter(rect: _rect),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onPanDown: (detail) {
                        setState(() {
                          _start = detail.localPosition;
                        });
                      },
                      onPanUpdate: (detail) {
                        setState(() {
                          _finish = detail.localPosition;
                          _rect = Rect.fromPoints(_start, _finish);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            height: 51,
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: double.infinity,
                  child: RaisedButton(
                    color: Colors.red,
                    child: Text(
                      "Back",
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Colors.white),
                    ),
                    onPressed: () {
                      _pageViewController.previousPage(
                          duration: Duration(milliseconds: 151),
                          curve: Curves.ease);
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: PageView(
                    controller: _pageViewController,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          "Select Reference",
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          _referenceRect = _rect;
                          _pageViewController.nextPage(
                              duration: Duration(milliseconds: 151),
                              curve: Curves.ease);
                          setState(() {
                            _rect = null;
                          });
                        },
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          "Select Object",
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          _objectRect = _rect;
                          _pageViewController.nextPage(
                              duration: Duration(milliseconds: 151),
                              curve: Curves.ease);
                          setState(() {
                            _rect = null;
                          });
                        },
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          "Show Result",
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () async {
                          var objectLength = _objectRect.height /
                              (_referenceRect.height / A4Height);
                          var objectWidth = _objectRect.width /
                              (_referenceRect.height / A4Height);
                          objectLength =
                              double.parse(objectLength.toStringAsFixed(2));
                          objectWidth =
                              double.parse(objectWidth.toStringAsFixed(2));
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Saved!",
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                    ListTile(
                                      leading: Text("Object Length:"),
                                      title: Text("$objectLength"),
                                      trailing: Text("In"),
                                    ),
                                    ListTile(
                                      leading: Text("Object Width:"),
                                      title: Text("$objectWidth"),
                                      trailing: Text("In"),
                                    ),
                                    RaisedButton(
                                      color: Colors.blue,
                                      child: Text(
                                        "Done",
                                        style: Theme.of(context)
                                            .textTheme
                                            .button
                                            .copyWith(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyRectPainter extends CustomPainter {
  MyRectPainter({this.rect});
  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    if (rect != null) {
      canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.green);
    } else {
      canvas.drawRect(Rect.fromPoints(Offset(0, 0), Offset(0, 0)), Paint());
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
