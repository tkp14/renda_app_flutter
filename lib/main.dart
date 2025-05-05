import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
void main() {
  runApp(TapCounterApp());
}

class TapCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '連打マン',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Color(0xFFE3F2FD),
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 20),
        ),
      ),
      home: TapGamePage(),
      debugShowCheckedModeBanner: false,
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
  List<int> _scoreHistory = [];
  bool _isPlaying = false;
  Timer? _timer;
  bool _isCountingDown = false;
  int _countdown = 3;
  int _highScore = 0;
  int _selectedDuration = 10;
  int _lastScore = 0; // 👈 最後のスコアを保存する変数

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _loadScoreHistory();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', score);
  }

  Future<void> _loadScoreHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scoreHistory = prefs
              .getStringList('score_history')
              ?.map((e) => int.parse(e))
              .toList() ??
          [];
    });
  }

  Future<void> _saveScoreHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'score_history', _scoreHistory.map((e) => e.toString()).toList());
  }

  void _startGame() {
    setState(() {
      _counter = 0;
      _timeLeft = _selectedDuration;
      _isPlaying = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft == 0) {
          _isPlaying = false;
          _timer?.cancel();
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    if (_counter > _highScore) {
      _saveHighScore(_counter);
      setState(() {
        _highScore = _counter;
      });
    }
    setState(() {
      _lastScore = _counter; // 👈 最後のスコアを保存
      _scoreHistory.insert(0, _counter);
      if (_scoreHistory.length > 10) {
        _scoreHistory = _scoreHistory.sublist(0, 10);
      }
    });
    _saveScoreHistory();
    _showResultDialog();
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
        title: Text('結果発表', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('あなたのスコアは $_counter 回です！\nハイスコア: $_highScore 回'),
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

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown == 0) {
          timer.cancel();
          _isCountingDown = false;
          _startGame();
        }
      });
    });
  }

  // スコアをシェアする関数
  void _shareScore() {
    final message = '🎯 連打マンで $_lastScore 回タップしたよ！君も挑戦してみて！ #連打マン';
    Share.share(message, subject: '連打マン結果');
  }

  void _shareToX() async {
    final message = '🎯 連打マンで $_lastScore 回タップしたよ！君も挑戦してみて！ #連打マン';
    final url =
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xを開けませんでした')),
      );
    }
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
        title: Text('連打マン'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('残り時間',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                _isCountingDown
                    ? Text(
                        _countdown > 0 ? '$_countdown' : 'スタート！',
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      )
                    : Text('$_timeLeft 秒',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                Text('タップ数',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text('$_counter',
                    style:
                        TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                Text('制限時間を選択', style: TextStyle(fontSize: 20)),
                DropdownButton<int>(
                  value: _selectedDuration,
                  items: [5, 10, 30].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value 秒'),
                    );
                  }).toList(),
                  onChanged: _isPlaying || _isCountingDown
                      ? null
                      : (value) {
                          setState(() {
                            _selectedDuration = value!;
                          });
                        },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (!_isPlaying && !_isCountingDown) {
                      _startCountdown();
                    } else if (_isPlaying) {
                      _incrementCounter();
                    }
                  },
                  child: Text(
                    _isPlaying ? 'タップ！' : 'スタート',
                    style: TextStyle(fontSize: 24),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed:
                      (_isPlaying || _isCountingDown) ? null : _shareScore,
                  icon: Icon(Icons.share),
                  label: Text('スコアをシェア'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: (_isPlaying || _isCountingDown) ? null : _shareToX,
                  icon: Icon(Icons.alternate_email),
                  label: Text('Xでシェア'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    '🏆 スコア履歴',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: _scoreHistory.isEmpty
                      ? Center(child: Text('まだスコアがありません'))
                      : ListView.builder(
                          itemCount: _scoreHistory.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              color: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  '${_scoreHistory[index]} 回',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
