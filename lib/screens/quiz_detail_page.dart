import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_result_page.dart';

const primaryBg = Color(0xFFEEF4F6);
const primaryGreen = Color(0xFF134D3F);

class QuizDetailPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> questions;

  const QuizDetailPage({
    super.key,
    required this.category,
    required this.questions,
  });

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  int index = 0;
  int score = 0;
  int timeLeft = 15;
  Timer? timer;

  int? selectedIndex;
  bool answered = false;
  bool quizFinished = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 15;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || quizFinished) {
        t.cancel();
        return;
      }

      if (timeLeft == 0) {
        t.cancel();
        nextQuestion();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void selectAnswer(int i) {
    if (answered) return;

    final correct = widget.questions[index]["answer"];

    setState(() {
      selectedIndex = i;
      answered = true;

      if (i == correct) score++;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!quizFinished && mounted) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (!mounted || quizFinished) return;

    if (index < widget.questions.length - 1) {
      setState(() {
        index++;
        selectedIndex = null;
        answered = false;
      });

      startTimer();
    } else {
      finishQuiz();
    }
  }

  Future<void> finishQuiz() async {
    quizFinished = true;
    timer?.cancel();


    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt("totalQuiz") ?? 0;
    await prefs.setInt("totalQuiz", total + 1);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultPage(
          score: score,
          total: widget.questions.length,
          category: widget.category,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[index];

    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        backgroundColor: primaryBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (index + 1) / widget.questions.length,
                  color: primaryGreen,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 6),
                Text("Question ${index + 1} / ${widget.questions.length}"),
              ],
            ),
          ),

          Text(
            "$timeLeft s ⏱",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 20),


          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    q["question"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ...List.generate(q["options"].length, (i) {
                  final correct = q["answer"];

                  Color bg = Colors.white;
                  Color border = Colors.grey.shade300;

                  if (answered) {
                    if (i == correct) {
                      bg = Colors.green.shade100;
                      border = Colors.green;
                    } else if (i == selectedIndex) {
                      bg = Colors.red.shade100;
                      border = Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () => selectAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: 2),
                      ),
                      child: Text(q["options"][i]),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}