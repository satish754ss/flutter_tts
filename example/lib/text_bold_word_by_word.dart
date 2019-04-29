import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

GlobalKey<TextSpeakWordsByWordsState> textToSpeach =
    new GlobalKey<TextSpeakWordsByWordsState>();

class TextSpeakWordByWord extends StatefulWidget {
  final String text;
  TextSpeakWordByWord({Key key, @required this.text}) : super(key: key);
  @override
  TextSpeakWordsByWordsState createState() => new TextSpeakWordsByWordsState();
}

class TextSpeakWordsByWordsState extends State<TextSpeakWordByWord> {
  String text;
  bool isPlaying = false, isPause = true;
  List<String> listOfLines = [];
  FlutterTts flutterTts;
  List<int> colorStatus;
  int startIndex = 0, endIndex = 0, colorIndex = 0, colorIndex1 = -1;
  String start, middle, end;
  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setSpeechRate(.78);
    init();
    text = widget.text;
  }

  void init() {
    flutterTts.startHandler = () {};
    flutterTts.completionHandler = () {
      setState(() {
        isPause = true;
        colorIndex = 0;
        colorIndex1 = -1;
      });
    };

    flutterTts.errorHandler = (e) {
      print(e);
    };
  }

  highlight() {
    setState(() {});
    colorIndex++;
  }

  pause() {
    flutterTts.stop().then((s) {
      if (s == 1) {
        isPause = true;
        setState(() {});
      }
    });
  }

  speak() {
    final s =
        text.split(" ").getRange(colorIndex, text.split(" ").length).join(" ");
    flutterTts.speak(s).then((s) {
      if (s == 1) {
        isPause = false;
        colorIndex1 = -1;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('word by word');
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 5, child: _buildText()),
        ],
      ),
    );
  }

  Widget _text(String s, int index) {
    return InkWell(
      onLongPress: () {
        if (isPause)
          setState(() {
            colorIndex1 = index;
          });
      },
      child: Text(s + ' ',
          style: TextStyle(
            fontSize: 23,
            color: (colorIndex - 1 == index || colorIndex1 == index)
                ? Colors.red
                : Colors.black54,
          )),
    );
  }

  Widget _buildText() {
    int index = 0;
    return Wrap(
      children: text.split(" ").map((s) {
        return _text(s, index++);
      }).toList(),
    );
  }
}
