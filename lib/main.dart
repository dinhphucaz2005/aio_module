import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(const AIOAudioApp());

class AIOAudioApp extends StatelessWidget {
  const AIOAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIO Audio Module',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  List<double> _audioLevels = [];
  final int _barCount = 50;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);

    // Initialize audio levels
    _audioLevels = List.generate(_barCount, (index) => Random().nextDouble());

    _startMockAudioAnimation();
  }

  void _startMockAudioAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPlaying) {
        setState(() {
          // Generate random audio levels to simulate real audio data
          for (int i = 0; i < _barCount; i++) {
            _audioLevels[i] = Random().nextDouble() * 0.8 + 0.1;
          }
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        // Set all bars to minimum height when paused
        _audioLevels = List.generate(_barCount, (index) => 0.1);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Audio Visualizer', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mock song info
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text('Mock Audio Track', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Demo Artist', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),

          // Audio Visualizer Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: CustomPaint(painter: AudioVisualizerPainter(_audioLevels), child: Container()),
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40)),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.deepPurple, size: 60),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next, color: Colors.white, size: 40)),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class AudioVisualizerPainter extends CustomPainter {
  final List<double> audioLevels;

  AudioVisualizerPainter(this.audioLevels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = size.width / audioLevels.length;
    final maxBarHeight = size.height * 0.8;

    for (int i = 0; i < audioLevels.length; i++) {
      final barHeight = audioLevels[i] * maxBarHeight;
      final x = i * barWidth;
      final y = size.height - barHeight;

      // Create gradient effect for bars
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.deepPurple, Colors.purple.shade300, Colors.pink.shade200],
      );

      paint.shader = gradient.createShader(Rect.fromLTWH(x, y, barWidth - 2, barHeight));

      // Draw the bar with rounded corners
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x + 1, y, barWidth - 2, barHeight), const Radius.circular(2));

      canvas.drawRRect(rect, paint);

      // Add glow effect
      paint.shader = null;
      paint.color = Colors.deepPurple.withAlpha((0.3 * 0xFF).toInt());
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(rect, paint);
      paint.maskFilter = null;
    }

    // Draw center line
    paint.color = Colors.white.withAlpha((0.2 * 0xFF).toInt());
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
