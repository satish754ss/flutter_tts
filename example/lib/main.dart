import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts_example/text_to_speach.dart';

FlutterTts flutterTts = FlutterTts();
String eng =
    "Look at these beautiful horses and elephants! Who brought them here? squealed Ahilya. Reluctantly, she tore her eyes away from the beautiful animals – it would get dark soon! She hurried inside the temple and lit a lamp. Ahilya closed her eyes and bowed in prayer.";
String hindi =
    "आजकल के समय में निबंध लिखना एक महत्वपूर्ण विषय बन चुका है, खासतौर से छात्रों के लिए। ऐसे कई अवसर आते हैं, जब आपको ";
String tel = "ఒకానొకప్పుడు ఒక ఊరిలో ఒక అమాయకపు పిచుక వుండేది";
String gujrati =
    "એક પોપટ હતો. તેનું નામ હતુ મિઠ્ઠુરામ. તેનું ઘર હતુ એક પિંજરુ, તે જ તેની દુનિયા હતી. મિઠ્ઠુરામનો અવાજ ખૂબ સારો હતો પણ તે ફક્ત રાત્રે જ ગાતો હતો";
enum Lan { eng, hin, guj }
void main() => runApp(MaterialApp(home: Scaffold(body: Test())));

class Test extends StatefulWidget {
  @override
  _TestState createState() => new _TestState();
}

class _TestState extends State<Test> {
  bool tts = false;
  Lan lang = Lan.eng;
  bool isPause = false;

  List<FlutterTextToSpeach> list = List<FlutterTextToSpeach>();
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < page.length; i++) {
      list.add(FlutterTextToSpeach());
    }

    list.forEach((s) {
      print(s.textToSpeach);
    });
  }

  List<String> page = [eng, eng];
  int t = 0;
  @override
  Widget build(BuildContext context) {
    int index = 0;
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          flex: 5,
          child: PageView(
            onPageChanged: (i) {
              t = i;
              setState(() {
                isPause = false;
              });
            },
            children: page.map((s) {
              return TextToSpeach(
                onLongPress: (s) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return FractionallySizedBox(
                          heightFactor: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 0.5
                              : 0.8,
                          widthFactor: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 0.8
                              : 0.4,
                          child: textDescriptionDialog(
                              context, s, 'textDesciption'));
                    },
                  );
                },
                fullText: s,
                keys: list[index++],
                onComplete: () => {
                      setState(() {
                        isPause = false;
                      })
                    },
              );
            }).toList(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                  child: !isPause ? Text('Play') : Text('pause'),
                  onPressed: () async {
                    print('page $t');
                    if (!isPause) {
                      list[t].speak().then((s) {
                        setState(() {
                          isPause = true;
                        });
                      });
                    } else {
                      await list[t].pause().then((s) {
                        setState(() {
                          isPause = false;
                        });
                      });
                    }
                  }),
            ],
          ),
        )
      ],
    );
  }
}

Widget textDescriptionDialog(
    BuildContext context, String text, String textDesciption) {
  text = text.replaceAll(new RegExp(r'[^\w\s]+'), '');
  final mediaQuery = MediaQuery.of(context);
  return new Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20.0),
      ),
    ),
    child: Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.close),
                  iconSize: mediaQuery.size.height * 0.07,
                  color: Colors.black,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              new IconButton(
                  icon: new Icon(Icons.volume_up),
                  iconSize: mediaQuery.size.height * 0.07,
                  color: Colors.black,
                  onPressed: () {
                    flutterTts.speak(text);
                  }),
            ],
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: mediaQuery.size.height * 0.05, color: Colors.green),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              textDesciption + '$text',
              style: TextStyle(
                  fontSize: mediaQuery.orientation == Orientation.portrait
                      ? mediaQuery.size.height * 0.02
                      : mediaQuery.size.height * 0.03,
                  color: Colors.black),
            ),
          )
        ],
      ),
    ),
  );
}
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// enum TtsState { playing, stopped }

// class _MyAppState extends State<MyApp> {
//   FlutterTts flutterTts;
//   dynamic languages;
//   dynamic voices;
//   String language;
//   String voice;
//   String text, text1;
//   String _newVoiceText;

//   TtsState ttsState = TtsState.stopped;

//   get isPlaying => ttsState == TtsState.playing;
//   get isStopped => ttsState == TtsState.stopped;

//   @override
//   initState() {
//     super.initState();
//     initTts();
//     text = tel;
//     text1 = gujrati;
//   }

//   initTts() async {
//     flutterTts = FlutterTts();
//     var l = await flutterTts.getLanguages;
//     // flutterTts.setLanguage("hi-IN");
//     print(l);
//     if (Platform.isAndroid) {
//       flutterTts.ttsInitHandler(() {
//         _getLanguages();
//         _getVoices();
//       });
//     } else if (Platform.isIOS) {
//       _getLanguages();
//     }

//     flutterTts.setStartHandler(() {
//       setState(() {
//         ttsState = TtsState.playing;
//       });
//     });

//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//     });

//     flutterTts.setErrorHandler((msg) {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//     });
//   }

//   Future _getLanguages() async {
//     languages = await flutterTts.getLanguages;
//     if (languages != null) setState(() => languages);
//   }

//   Future _getVoices() async {
//     voices = await flutterTts.getVoices;
//     if (voices != null) setState(() => voices);
//   }

//   Future _speak() async {
//     var result = await flutterTts.speak(text);
//     if (result == 1) setState(() => ttsState = TtsState.playing);
//   }

//   Future _stop() async {
//     var result = await flutterTts.stop();
//     if (result == 1) setState(() => ttsState = TtsState.stopped);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     flutterTts.stop();
//   }

//   List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
//     var items = List<DropdownMenuItem<String>>();
//     for (String type in languages) {
//       items.add(DropdownMenuItem(value: type, child: Text(type)));
//     }
//     return items;
//   }

//   List<DropdownMenuItem<String>> getVoiceDropDownMenuItems() {
//     var items = List<DropdownMenuItem<String>>();
//     for (String type in voices) {
//       items.add(DropdownMenuItem(value: type, child: Text(type)));
//     }
//     return items;
//   }

//   void changedLanguageDropDownItem(String selectedType) {
//     setState(() {
//       language = selectedType;
//       flutterTts.setLanguage(language);
//     });
//   }

//   void changedVoiceDropDownItem(String selectedType) {
//     setState(() {
//       voice = selectedType;
//       flutterTts.setVoice(voice);
//     });
//   }

//   void _onChange(String text) {
//     setState(() {
//       _newVoiceText = text;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             appBar: AppBar(
//               title: Text('Flutter TTS'),
//             ),
//             body: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Column(children: [
//                   Text("telugu"),
//                   inputSection(text),
//                   btnSection(),
//                   Text('Gujarti'),
//                   inputSection(text1),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: <Widget>[
//                       IconButton(
//                           onPressed: () {
//                             flutterTts.speak(text1);
//                           },
//                           icon: Icon(Icons.play_arrow)),
//                       IconButton(
//                         onPressed: () {
//                           flutterTts.stop();
//                         },
//                         icon: Icon(Icons.stop),
//                       )
//                     ],
//                   ),
//                   languages != null ? languageDropDownSection() : Text(""),
//                   voices != null ? voiceDropDownSection() : Text("")
//                 ]))));
//   }

//   Widget inputSection(String t) => Container(
//       alignment: Alignment.topCenter,
//       padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
//       child: Text(t));

//   Widget btnSection() => Container(
//       padding: EdgeInsets.only(top: 50.0),
//       child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//         _buildButtonColumn(
//             Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
//         _buildButtonColumn(
//             Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
//       ]));

//   Widget languageDropDownSection() => Container(
//       padding: EdgeInsets.only(top: 50.0),
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         DropdownButton(
//           value: language,
//           items: getLanguageDropDownMenuItems(),
//           onChanged: changedLanguageDropDownItem,
//         )
//       ]));

//   Widget voiceDropDownSection() => Container(
//       padding: EdgeInsets.only(top: 50.0),
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         DropdownButton(
//           value: voice,
//           items: getVoiceDropDownMenuItems(),
//           onChanged: changedVoiceDropDownItem,
//         )
//       ]));

//   Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
//       String label, Function func) {
//     return Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//               icon: Icon(icon),
//               color: color,
//               splashColor: splashColor,
//               onPressed: () => func()),
//           Container(
//               margin: const EdgeInsets.only(top: 8.0),
//               child: Text(label,
//                   style: TextStyle(
//                       fontSize: 12.0,
//                       fontWeight: FontWeight.w400,
//                       color: color))),
//         ]);
//   }
// }

// enum PlayingStatus { play, pause, stop, isPlaying }

// class TextToSpeach extends StatefulWidget {
//   final String text;
//   final PlayingStatus playingStatus;
//   TextToSpeach({Key key, this.playingStatus, this.text}) : super(key: key);
//   @override
//   _TextToSpeachState createState() => new _TextToSpeachState();
// }

// class _TextToSpeachState extends State<TextToSpeach> {
//   @override
//   Widget build(BuildContext context) {
//     return new Container(
//       child: Text(widget.text ?? ""),
//     );
//   }
// }
