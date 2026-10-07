import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'quiz_screen.dart';

const primaryGreen = Color(0xFF134D3F);

class QuizResultPage extends StatefulWidget {
  final int score;
  final int total;
  final String category;

  const QuizResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.category,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool get passed => widget.score >= widget.total * 0.6;

  double get percentage => widget.score / widget.total;

  String get grade {
    if (percentage == 1.0) return "Perfect! 🏆";
    if (percentage >= 0.8) return "Excellent! 🎉";
    if (percentage >= 0.6) return "Good Job! 👍";
    if (percentage >= 0.4) return "Keep Trying 📚";
    return "Needs Work 💪";
  }

  Color get bgColor {
    if (percentage == 1.0) return const Color(0xFF1B5E20);
    if (percentage >= 0.8) return const Color(0xFF2E7D32);
    if (percentage >= 0.6) return const Color(0xFF1565C0);
    if (percentage >= 0.4) return const Color(0xFFE65100);
    return const Color(0xFFB71C1C);
  }

  @override
  void initState() {
    super.initState();


    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    if (passed) _confettiController.play();


    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 25,
              minBlastForce: 8,
              emissionFrequency: 0.04,
              numberOfParticles: 50,
              gravity: 0.25,
              shouldLoop: false,
              colors: const [
                Colors.white,
                Colors.greenAccent,
                Colors.blue,
                Colors.yellow,
                Colors.orange,
                Colors.pink,
                Colors.cyan,
              ],
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white38, width: 3),
                      ),
                      child: Icon(
                        passed ? Icons.emoji_events_rounded : Icons.school_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    widget.category,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    grade,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.score),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return Text(
                        "$value",
                        style: const TextStyle(
                          fontSize: 90,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      );
                    },
                  ),

                  Text(
                    "out of ${widget.total}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white60,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _ScoreBar(percentage: percentage),

                  const SizedBox(height: 10),

                  Text(
                    "${(percentage * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 44),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        "Retry Quiz",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizDetailPage(
                              category: widget.category,
                              questions: quizData[widget.category]!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),


                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text(
                        "Go Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScoreBar extends StatelessWidget {
  final double percentage;
  const _ScoreBar({required this.percentage});

  Color get barColor {
    if (percentage >= 0.8) return Colors.greenAccent;
    if (percentage >= 0.6) return Colors.lightBlueAccent;
    if (percentage >= 0.4) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 14,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        );
      },
    );
  }
}