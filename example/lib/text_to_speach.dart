import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_version/get_version.dart';
import 'package:flutter/services.dart';

class FlutterTextToSpeach {
  GlobalKey<TextToSpeachState> textToSpeach;

  FlutterTextToSpeach() {
    textToSpeach = new GlobalKey<TextToSpeachState>();
  }
  Future<dynamic> speak() => textToSpeach.currentState.speak();

  Future<dynamic> pause() => textToSpeach.currentState.pause();
}

TextStyle textStyle = TextStyle(fontSize: 23, color: Colors.black);

class TextToSpeach extends StatefulWidget {
  final Function onComplete;
  final String fullText;
  final TextStyle textStyle;
  final Color highLightColor;
  final Function(String) onTap;
  final Function(String) onLongPress;
  final double setSpeechRate;
  final FlutterTextToSpeach keys;
  TextToSpeach(
      {@required this.keys,
      @required this.fullText,
      this.setSpeechRate = .78,
      this.onTap,
      this.onLongPress,
      this.onComplete,
      this.highLightColor = Colors.red,
      this.textStyle = const TextStyle(fontSize: 15, color: Colors.black54)})
      : assert(fullText != null),
        super(key: keys.textToSpeach);
  @override
  TextToSpeachState createState() => new TextToSpeachState();
}

class TextToSpeachState extends State<TextToSpeach> {
  bool isPlaying = false;
  List<String> listOfLines = [];
  int incr = 0;

  FlutterTts flutterTts;
  String text;
  String startText = '', middleText = '', endText = '';
  int version = 0;
  List<String> words;
  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setSpeechRate(widget.setSpeechRate);
    text = widget.fullText.trim();
    if (!text.substring(text.length).contains(RegExp('[.]'))) {
      text = text + '.';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => reset());
    initTts();
    getVersion();
  }

  reset() {
    pause();
    setState(() {
      startText = '';
      middleText = '';
      endText = text;
      incr = 0;
    });
  }

  getVersion() async {
    String platformVersion;
    try {
      platformVersion = await GetVersion.platformVersion;
      print(platformVersion.split(" "));
      var s = platformVersion.split(" ")[1];
      s = s.substring(0, 1);
      version = int.parse(s).floor();
      print(version);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
  }

  initTts() {
    words = List<String>();
    var string = '';
    listOfLines = List<String>();
    words = text.split(" ");
    for (var i = 0; i < words.length; i++) {
      string = string + words[i] + ' ';
      if (words[i].contains(RegExp('[,.|!]'))) {
        listOfLines.add(string);
        string = '';
      }
    }
    flutterTts.completionHandler = () {
      if (incr == listOfLines.length - 1) {
        setState(() {
          incr = 0;
          startText = '';
          middleText = '';
          endText = text;
          widget.onComplete();
          words = text.split(" ");
        });
      } else {
        if (version < 8) {
          incr++;
          speak();
        }
      }
      if (words.isEmpty) {
        setState(() {
          reset();
          endText = text;
          widget.onComplete();
          words = text.split(" ");
        });
      }
    };

    flutterTts.onRangeStart = (start, end) {
      highlightApi26(start, end);
    };
  }

  highlight() {
    var s = '', e = '';
    setState(() {
      for (var i = 0; i < incr; i++) s = s + listOfLines[i];
      startText = s;
      middleText = listOfLines[incr];
      for (var i = incr + 1; i < listOfLines.length; i++) {
        e = e + listOfLines[i];
      }
      endText = e;
    });
  }

  void highlightApi26(int start, int end) {
    setState(() {
      startText = startText + middleText;
      middleText = '';
      middleText = words.removeAt(0) + " ";
      endText = '';
      endText = words.join(" ");
    });
  }

  Future<dynamic> pause() => flutterTts.stop().then((s) {
        if (s == 1) {}
      });

  Future<dynamic> speak() async {
    final middle = version >= 8 ? words.join(' ') : listOfLines[incr];
    return await _speak(middle);
  }

  Future<dynamic> _speak(String text) => flutterTts.speak(text).then((s) {
        if (version < 8) {
          highlight();
        } else {
          setState(() {});
        }
      });

  onComplete() => setState(() {
        incr = 0;
      });

  @override
  Widget build(BuildContext context) {
    var index = 0;
    var space = ' ';
    final children = <Widget>[];
    Widget _text(String data, String space) {
      return InkWell(
        onTap: widget.onTap != null ? () => widget.onTap(data) : null,
        onLongPress:
            widget.onLongPress != null ? () => widget.onLongPress(data) : null,
        child: Text(
          data + space,
          style: TextStyle(fontSize: 23),
        ),
      );
    }

    if (startText != '')
      startText.split(" ").map((s) {
        index++;
        if (index == startText.split(" ").length) space = '';
        children.add(_text(s, space));
      }).toList();
    space = ' ';
    index = 0;
    if (middleText != '')
      middleText.split(" ").map((s) {
        index++;
        if (index == middleText.split(" ").length) space = '';
        children.add(InkWell(
          onTap: widget.onTap != null ? () => widget.onTap(s) : null,
          onLongPress:
              widget.onLongPress != null ? () => widget.onLongPress(s) : null,
          child: Text(
            s + space,
            style: TextStyle(fontSize: 23, color: Colors.red),
          ),
        ));
      }).toList();
    space = ' ';
    index = 0;
    if (endText != '')
      endText.split(" ").map((s) {
        index++;
        if (index == endText.split(" ").length) space = '';
        children.add(_text(s, space));
      }).toList();
    space = ' ';
    index = 0;
    Widget _buildText() {
      return Wrap(
        children: children,
      );
    }

    return _buildText();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}

Map<int, int> get sdkIntValue {
  return {5: 21, 6: 23, 7: 25, 8: 26, 9: 28};
}
