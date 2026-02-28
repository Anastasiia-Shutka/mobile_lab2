import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const PartyLampPage(),
    );
  }
}

class PartyLampPage extends StatefulWidget {
  const PartyLampPage({super.key});

  @override
  State<PartyLampPage> createState() => _PartyLampPageState();
}

class _PartyLampPageState extends State<PartyLampPage> {
  Color _lampColor = Colors.blueGrey;
  String _status = 'System Ready';
  final _controller = TextEditingController();
  Timer? _partyTimer;

  final Map<String, Color> _colors = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'pink': Colors.pink,
    'purple': Colors.purple,
    'cyan': Colors.cyan,
    'amber': Colors.amber,
    'brown': Colors.brown,
    'white': Colors.white,
    'black': Colors.black,
    'gold': const Color(0xFFFFD700),
    'silver': const Color(0xFFC0C0C0),
    'teal': Colors.teal,
  };

  void _onCommand(String val) {
    _partyTimer?.cancel();
    final input = val.trim().toLowerCase();

    setState(() {
      if (input == 'party') {
        _status = 'Party Mode On!';
        _startDisco();
      } else if (input == 'avada kedavra') {
        _lampColor = Colors.black;
        _status = 'System Shutdown';
      } else if (_colors.containsKey(input)) {
        _lampColor = _colors[input]!;
        _status = 'Color: $input';
      } else if (input.isEmpty) {
        _status = 'Waiting for command...';
      } else {
        _status = "Error: '$input' unknown";
      }
    });
    _controller.clear();
  }

  void _startDisco() {
    _partyTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _lampColor = Color((Random().nextDouble() * 0xFFFFFF).toInt())
        .withValues(alpha: 1);
      });
    });
  }

  @override
  void dispose() {
    _partyTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT RGB Controller'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _lampColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _lampColor.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.lightbulb_outline, size: 70, 
                color: Colors.white70),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Color, Party or Avada Kedavra',
                  ),
                  onSubmitted: _onCommand,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _onCommand(_controller.text),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 45),
                ),
                child: const Text('SEND'),
              ),
              const SizedBox(height: 40),
              Text(
                _status,
                style: const TextStyle(fontSize: 16, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
