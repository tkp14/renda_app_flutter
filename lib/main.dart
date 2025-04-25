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
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Color(0xFFE3F2FD), // 👈 淡いブルーの背景色
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 20),
        ),
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
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 👈 横に余白
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('残り時間',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              Text('$_timeLeft 秒',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              Text('タップ数',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              Text('$_counter',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isPlaying ? _incrementCounter : _startGame,
                child: Text(_isPlaying ? 'タップ！' : 'スタート'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // 👈 角丸
                  ),
                  elevation: 6, // 👈 影
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  textStyle: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
