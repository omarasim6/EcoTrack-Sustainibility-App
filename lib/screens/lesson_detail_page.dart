import 'package:flutter/material.dart';
import 'video_player_page.dart';
import 'quiz_screen.dart';

const primaryGreen = Color(0xFF134D3F);
const bgColor = Color(0xFFEEF4F6);

class LessonDetailPage extends StatefulWidget {
  final Map lesson;
  final bool isDone;
  final bool isSaved;
  final VoidCallback onComplete;
  final VoidCallback onBookmark;
  final String category;

  const LessonDetailPage({
    super.key,
    required this.lesson,
    required this.category,
    required this.isDone,
    required this.isSaved,
    required this.onComplete,
    required this.onBookmark,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late bool isDone;
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isDone = widget.isDone;
    isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: primaryGreen,
            ),
            onPressed: () {
              setState(() => isSaved = !isSaved);
              widget.onBookmark();
            },
          )
        ],
      ),

      body: Column(
        children: [
          Hero(
            tag: widget.lesson["id"],
            child: Image.network(
              widget.lesson["image"],
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson["title"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.lesson["content"],
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizDetailPage(
                              category: widget.category,
                              questions: quizData[widget.category]!,
                            ),
                          ),
                        );

                        if (result != null && result >= 6) {
                          setState(() => isDone = true);
                          widget.onComplete();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryGreen, width: 2),
                        backgroundColor: const Color(0xFFEEF4F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Take Quiz 🧠",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        final videoMap = {
                          "c1": "G4H1N_yXBiA",
                          "c2": "oJAbATJCugs",
                          "c3": "8q7_aV8eLUE",
                          "w1": "OasbYWF4_S8",
                          "w2": "ODni_Bey154",
                          "w3": "JcZcJ3yU4uE",
                          "e1": "1kUE0BZtTRc",
                          "e2": "1-g73ty9v04",
                          "e3": "zaXBVYr9Ij0",
                          "wa1": "8sPjH6h2KfQ",
                          "wa2": "Om42Lppkd9w",
                          "wa3": "R1S3tP6pR1Q",
                          "b1": "3pZ7h4k4Cq0",
                          "b2": "3vijLre760w",
                          "b3": "FZ9j1zYF3X0",
                          "s1": "7V8oFI4GYMY",
                          "s2": "6jQ7y_qQYUA",
                          "s3": "8G7lZ0M0pJ8",
                        };

                        final id = widget.lesson["id"];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              videoId: videoMap[id]!,
                              title: widget.lesson["title"],
                              lessonId: id,
                            ),
                          ),
                        );
                      },
                          child: const Text(
                            "Watch Video 🎥",
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                    ),


                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => isDone = !isDone);
                        widget.onComplete();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isDone
                            ? "Mark as Incomplete"
                            : "Mark as Complete",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}