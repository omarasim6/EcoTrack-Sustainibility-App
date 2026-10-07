import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quiz_result_page.dart';

const primaryGreen = Color(0xFF134D3F);
const bgColor = Color(0xFFEEF4F6);

Future<bool> _showStyledDialog({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  required Color confirmColor,
}) async {
  return await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 28),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        cancelLabel,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ) ??
      false;
}


class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, int> scores = {};

  final List<Map<String, dynamic>> categories = [
    {"title": "Climate", "icon": Icons.public},
    {"title": "Waste", "icon": Icons.delete_outline},
    {"title": "Energy", "icon": Icons.bolt},
    {"title": "Water", "icon": Icons.water_drop},
    {"title": "Biodiversity", "icon": Icons.pets},
    {"title": "Sustainability", "icon": Icons.eco},
  ];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var cat in categories) {
        scores[cat["title"]] = prefs.getInt("quiz_${cat["title"]}") ?? 0;
      }
    });
  }

  Color getScoreColor(int score) {
    if (score >= 7) return Colors.green.shade100;
    if (score >= 5) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Color getScoreTextColor(int score) {
    if (score >= 7) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  Future<bool> _confirmStartQuiz(String title, int currentScore) async {
    if (currentScore > 0) {
      return _showStyledDialog(
        context: context,
        icon: Icons.refresh_rounded,
        iconColor: primaryGreen,
        iconBg: primaryGreen.withOpacity(0.08),
        title: "Restart Quiz?",
        body:
        "You already scored $currentScore/10 in $title.\nRetaking will only save a higher score.",
        cancelLabel: "Cancel",
        confirmLabel: "Restart",
        confirmColor: primaryGreen,
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Quiz",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final score = scores[cat["title"]] ?? 0;

          return GestureDetector(
            onTap: () async {
              final catTitle = cat["title"] as String;
              final currentScore = scores[catTitle] ?? 0;

              final canStart =
              await _confirmStartQuiz(catTitle, currentScore);
              if (!canStart || !mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizDetailPage(
                    category: catTitle,
                    questions: quizData[catTitle]!,
                  ),
                ),
              );

              await _loadScores();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                    Icon(cat["icon"] as IconData, color: primaryGreen),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat["title"],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          "10 Questions",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: getScoreColor(score),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$score/10",
                      style: TextStyle(
                        color: getScoreTextColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


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

      if (timeLeft <= 0) {
        t.cancel();
        if (!answered) setState(() => answered = true);
        Future.delayed(const Duration(milliseconds: 400), nextQuestion);
      } else {
        setState(() => timeLeft--);
      }
    });
  }


  void selectAnswer(int i) {
    if (answered || quizFinished) return;

    timer?.cancel();

    final correct = widget.questions[index]["answer"] as int;

    setState(() {
      selectedIndex = i;
      answered = true;
      if (i == correct) score++;
    });

    Future.delayed(const Duration(milliseconds: 700), nextQuestion);
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
    if (quizFinished) return;
    quizFinished = true;
    timer?.cancel();

    final prefs = await SharedPreferences.getInstance();

    final key = "quiz_${widget.category}";
    final prev = prefs.getInt(key) ?? 0;
    if (score > prev) await prefs.setInt(key, score);

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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        timer?.cancel();

        final exit = await _showStyledDialog(
          context: context,
          icon: Icons.exit_to_app_rounded,
          iconColor: Colors.red.shade400,
          iconBg: Colors.red.shade50,
          title: "Exit Quiz?",
          body:
          "Your progress on this quiz\nwill not be saved if you leave now.",
          cancelLabel: "Stay",
          confirmLabel: "Exit",
          confirmColor: Colors.red.shade400,
        );

        if (exit) {
          if (context.mounted) Navigator.of(context).pop();
        } else {
          if (!quizFinished) startTimer();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.category,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (index + 1) / widget.questions.length,
                    color: primaryGreen,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Question ${index + 1} / ${widget.questions.length}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _TimerWidget(timeLeft: timeLeft),

            const SizedBox(height: 16),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(index),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          q["question"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...List.generate(
                        (q["options"] as List).length,
                            (i) => _optionButton(
                          q["options"][i] as String,
                          i,
                          q["answer"] as int,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(String text, int i, int correctIndex) {
    Color bg = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Widget? trailingIcon;

    if (answered) {
      if (i == correctIndex) {
        bg = Colors.green.shade100;
        borderColor = Colors.green;
        trailingIcon =
        const Icon(Icons.check_circle, color: Colors.green);
      } else if (i == selectedIndex) {
        bg = Colors.red.shade100;
        borderColor = Colors.red;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      }
    }

    return GestureDetector(
      onTap: () => selectAnswer(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: answered && i == correctIndex
                    ? Colors.green
                    : answered && i == selectedIndex
                    ? Colors.red
                    : primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + i),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: answered &&
                        (i == correctIndex || i == selectedIndex)
                        ? Colors.white
                        : primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: const TextStyle(fontSize: 15))),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}


class _TimerWidget extends StatelessWidget {
  final int timeLeft;
  const _TimerWidget({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    final isUrgent = timeLeft <= 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:
      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isUrgent ? Colors.red : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer,
              color: isUrgent ? Colors.red : primaryGreen, size: 20),
          const SizedBox(width: 6),
          Text(
            "$timeLeft s",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

final Map<String, List<Map<String, dynamic>>> quizData = {
  "Climate": [
    {
      "question": "What is the main driver of global warming?",
      "options": ["Deforestation", "Greenhouse gases", "Ocean tides", "Wind patterns"],
      "answer": 1,
    },
    {
      "question": "Which gas has the highest impact on climate change?",
      "options": ["Oxygen", "Carbon dioxide", "Helium", "Hydrogen"],
      "answer": 1,
    },
    {
      "question": "What increases greenhouse gas emissions the most?",
      "options": ["Renewable energy", "Burning fossil fuels", "Planting trees", "Recycling"],
      "answer": 1,
    },
    {
      "question": "Which activity helps reduce climate change?",
      "options": ["Using coal", "Deforestation", "Using solar energy", "Driving more cars"],
      "answer": 2,
    },
    {
      "question": "What is the effect of deforestation on CO2?",
      "options": ["More oxygen", "Less CO2", "Increased CO2", "Cooler climate"],
      "answer": 2,
    },
    {
      "question": "Which sector produces the most emissions globally?",
      "options": ["Agriculture", "Energy production", "Education", "Healthcare"],
      "answer": 1,
    },
    {
      "question": "What is climate change mitigation?",
      "options": ["Increasing pollution", "Reducing emissions", "Ignoring climate", "Cutting trees"],
      "answer": 1,
    },
    {
      "question": "Which energy source is considered clean?",
      "options": ["Coal", "Oil", "Solar", "Diesel"],
      "answer": 2,
    },
    {
      "question": "What is global warming?",
      "options": ["Cooling of Earth", "Heating of Earth's surface", "Ocean freezing", "Rain increase only"],
      "answer": 1,
    },
    {
      "question": "Which natural element helps absorb CO2?",
      "options": ["Cars", "Factories", "Trees", "Plastic"],
      "answer": 2,
    },
  ],

  "Waste": [
    {
      "question": "What does recycling mean?",
      "options": ["Burning waste", "Reusing materials", "Dumping waste", "Ignoring waste"],
      "answer": 1,
    },
    {
      "question": "Which of these items is recyclable?",
      "options": ["Plastic bottle", "Food scraps", "Wet tissue", "Dirty cloth"],
      "answer": 0,
    },
    {
      "question": "What reduces landfill waste effectively?",
      "options": ["Recycling", "Throwing everything away", "Burning plastics", "Mixing all waste"],
      "answer": 0,
    },
    {
      "question": "What is composting?",
      "options": ["Burning waste", "Turning food waste into soil", "Plastic production", "Landfilling"],
      "answer": 1,
    },
    {
      "question": "Which type of waste is most hazardous?",
      "options": ["Organic waste", "E-waste", "Paper", "Leaves"],
      "answer": 1,
    },
    {
      "question": "What does 'Reduce' mean in the 3Rs?",
      "options": ["Use more", "Use fewer resources", "Burn waste", "Ignore waste"],
      "answer": 1,
    },
    {
      "question": "Which practice helps the environment most?",
      "options": ["Single-use plastic", "Recycling", "Dumping waste", "Littering"],
      "answer": 1,
    },
    {
      "question": "What primarily happens in landfills?",
      "options": ["Waste slowly decomposes", "Water becomes clean", "Air becomes pure", "Trees grow faster"],
      "answer": 0,
    },
    {
      "question": "What is e-waste?",
      "options": ["Food waste", "Electronic waste", "Water waste", "Paper waste"],
      "answer": 1,
    },
    {
      "question": "What is the best waste management practice?",
      "options": ["Reuse items", "Throw away immediately", "Burn all waste", "Ignore it"],
      "answer": 0,
    },
  ],

  "Energy": [
    {
      "question": "Which of these is a renewable energy source?",
      "options": ["Coal", "Solar", "Natural Gas", "Oil"],
      "answer": 1,
    },
    {
      "question": "What does energy efficiency mean?",
      "options": ["Using more energy", "Wasting energy", "Achieving the same output with less energy", "No energy use at all"],
      "answer": 2,
    },
    {
      "question": "Which energy source is non-renewable?",
      "options": ["Wind", "Solar", "Coal", "Hydropower"],
      "answer": 2,
    },
    {
      "question": "Which is the best clean energy source?",
      "options": ["Coal", "Diesel", "Solar", "Gas"],
      "answer": 2,
    },
    {
      "question": "Which action reduces household electricity use?",
      "options": ["Leaving lights on all day", "Using energy-saving bulbs", "Overusing AC", "Keeping machines idle"],
      "answer": 1,
    },
    {
      "question": "What natural resource powers wind energy?",
      "options": ["Water", "Air movement", "Coal", "Oil"],
      "answer": 1,
    },
    {
      "question": "Hydropower generates electricity using?",
      "options": ["Wind", "Flowing water", "Fire", "Gas"],
      "answer": 1,
    },
    {
      "question": "What do solar panels convert?",
      "options": ["Heat to gas", "Sunlight to electricity", "Wind to water", "Coal to air"],
      "answer": 1,
    },
    {
      "question": "Energy conservation means?",
      "options": ["Using more power", "Saving and reducing energy use", "Wasting energy daily", "Ignoring energy use"],
      "answer": 1,
    },
    {
      "question": "Fossil fuels are classified as?",
      "options": ["Renewable", "Non-renewable", "Infinite resources", "Always clean"],
      "answer": 1,
    },
  ],

  "Water": [
    {
      "question": "Why is water conservation important?",
      "options": ["Water is unlimited", "It is a limited resource", "There is no need", "There is too much water"],
      "answer": 1,
    },
    {
      "question": "Which is the most effective water-saving action?",
      "options": ["Leaving the tap open", "Fixing leaks promptly", "Taking long showers", "Wasting water daily"],
      "answer": 1,
    },
    {
      "question": "What is freshwater?",
      "options": ["Salty seawater", "Drinkable, low-salt water", "Ocean water", "Polluted water"],
      "answer": 1,
    },
    {
      "question": "Which of these pollutes water sources?",
      "options": ["Trees", "Plastic waste", "Rainfall", "Clean soil"],
      "answer": 1,
    },
    {
      "question": "What is water scarcity?",
      "options": ["Having too much water", "A lack of sufficient clean water", "Clean rivers everywhere", "Only floods"],
      "answer": 1,
    },
    {
      "question": "What is the best practice for water usage?",
      "options": ["Waste it freely", "Use it wisely and save it", "Pollute it", "Ignore it"],
      "answer": 1,
    },
    {
      "question": "What is rainwater harvesting?",
      "options": ["Wasting rain", "Collecting and storing rainwater", "Polluting water", "Draining rivers"],
      "answer": 1,
    },
    {
      "question": "Which sector uses the most water globally?",
      "options": ["Industry", "Reading", "Sleeping", "Walking"],
      "answer": 0,
    },
    {
      "question": "Safe drinking water must be?",
      "options": ["Dirty and cloudy", "Clean and treated", "Salty", "Colored"],
      "answer": 1,
    },
    {
      "question": "Water conservation directly helps?",
      "options": ["Increase waste", "Secure future water supply", "Cause more pollution", "Dry up rivers faster"],
      "answer": 1,
    },
  ],

  "Biodiversity": [
    {
      "question": "What is biodiversity?",
      "options": ["Only animals", "The variety of life on Earth", "Only plants", "Only humans"],
      "answer": 1,
    },
    {
      "question": "Which action supports biodiversity?",
      "options": ["Deforestation", "Protecting natural habitats", "Pollution", "Hunting endangered species"],
      "answer": 1,
    },
    {
      "question": "Loss of biodiversity can cause?",
      "options": ["Better ecosystem balance", "Ecosystem collapse", "More species", "Improved climate"],
      "answer": 1,
    },
    {
      "question": "Which animal is considered endangered?",
      "options": ["Common pigeon", "Tiger", "Crow", "Domestic cat"],
      "answer": 1,
    },
    {
      "question": "Forests primarily help by?",
      "options": ["Destroying animals", "Supporting diverse wildlife", "Polluting the air", "Drying up rivers"],
      "answer": 1,
    },
    {
      "question": "What is a habitat?",
      "options": ["An animal's food", "The natural living place of a species", "A type of water", "A kind of air"],
      "answer": 1,
    },
    {
      "question": "Which of these harms biodiversity?",
      "options": ["Conservation efforts", "Pollution", "Wildlife protection", "Planting native trees"],
      "answer": 1,
    },
    {
      "question": "Animals primarily depend on?",
      "options": ["Their ecosystem", "Mobile phones", "Cars", "Buildings"],
      "answer": 0,
    },
    {
      "question": "Extinction of a species means?",
      "options": ["Population growth", "Complete disappearance forever", "A population increase", "Migration to new areas"],
      "answer": 1,
    },
    {
      "question": "Protecting nature ultimately helps?",
      "options": ["Destroy all life", "Maintain a balanced ecosystem", "Pollute the earth", "Reduce oxygen levels"],
      "answer": 1,
    },
  ],

  "Sustainability": [
    {
      "question": "What does sustainability mean?",
      "options": ["Using resources wisely for the future", "Wasting resources freely", "Polluting without concern", "Ignoring nature"],
      "answer": 0,
    },
    {
      "question": "Which is a sustainable energy source?",
      "options": ["Coal", "Solar", "Diesel", "Oil"],
      "answer": 1,
    },
    {
      "question": "The main goal of sustainability is to?",
      "options": ["Destroy future resources", "Protect resources for future generations", "Waste all resources now", "Increase pollution"],
      "answer": 1,
    },
    {
      "question": "Which choice is more sustainable?",
      "options": ["Reusable shopping bags", "Single-use plastic bags", "Burning waste", "Littering"],
      "answer": 0,
    },
    {
      "question": "Sustainability covers which areas?",
      "options": ["Environment only", "People, planet, and economy together", "Only money and profit", "Only natural resources"],
      "answer": 1,
    },
    {
      "question": "Overuse of natural resources leads to?",
      "options": ["Sustained growth", "Resource shortage", "Perfect balance", "A cleaner earth"],
      "answer": 1,
    },
    {
      "question": "A sustainable lifestyle means?",
      "options": ["Wasteful living habits", "Eco-friendly, mindful habits", "Maximizing pollution", "Fast, unchecked consumption"],
      "answer": 1,
    },
    {
      "question": "Which is a clear example of sustainability?",
      "options": ["Large-scale deforestation", "Recycling and reusing materials", "Burning plastic waste", "Dumping chemicals in rivers"],
      "answer": 1,
    },
    {
      "question": "Future sustainability depends most on?",
      "options": ["The actions we take today", "Completely ignoring the environment", "Generating more waste", "Increasing pollution levels"],
      "answer": 0,
    },
    {
      "question": "The core idea of sustainability is?",
      "options": ["Use all resources as fast as possible", "Balance present needs without harming the future", "Destroy nature for profit", "Ignore environmental problems"],
      "answer": 1,
    },
  ],
};