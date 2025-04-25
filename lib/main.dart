import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(TapCounterApp());
}

class TapCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '連打アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TapGamePage(),
    );
  }
}

class TapGamePage extends StatefulWidget {
  @override
  _TapGamePageState createState() => _TapGamePageState();
}

class _TapGamePageState extends State<TapGamePage> {
  int _counter = 0;
  int _timeLeft = 10;
  bool _isPlaying = false;
  Timer? _timer;

  void _startGame() {
    setState(() {
      _counter = 0;
      _timeLeft = 10;
      _isPlaying = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft == 0) {
          _isPlaying = false;
          _timer?.cancel();
          _showResultDialog();
        }
      });
    });
  }

  void _incrementCounter() {
    if (_isPlaying) {
      setState(() {
        _counter++;
      });
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('結果発表'),
        content: Text('あなたのスコアは $_counter 回です！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('10秒連打チャレンジ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('残り時間: $_timeLeft 秒', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('タップ数: $_counter', style: TextStyle(fontSize: 32)),
            SizedBox(height: 40),
            _isPlaying
                ? ElevatedButton(
                    onPressed: _incrementCounter,
                    child: Text('タップ！'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: TextStyle(fontSize: 24),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _startGame,
                    child: Text('スタート'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: TextStyle(fontSize: 24),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
