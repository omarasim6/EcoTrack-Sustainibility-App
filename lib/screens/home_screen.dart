import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_home_page.dart';
import 'info_screen.dart';
import 'video_screen.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';
import 'daily_reward_popup.dart';

const primaryBg = Color(0xFFEEF4F6);
const primaryGreen = Color(0xFF134D3F);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isDrawerOpen = false;

  int streak = 1;
  int quizScore = 0;
  int videosWatched = 0;

  @override
  void initState() {
    super.initState();
    _initStreak();
  }

  Future<void> _initStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final currentEmail = prefs.getString('currentUser') ?? '';

    Map<String, dynamic> users = {};
    try {
      final raw = prefs.getString('users');
      if (raw != null && raw.isNotEmpty) users = jsonDecode(raw);
    } catch (_) {}

    final userData = Map<String, dynamic>.from(
      (users[currentEmail] as Map<String, dynamic>?) ?? {},
    );

    final int lastTime  = userData['last_open_time'] as int?
        ?? prefs.getInt('last_open_time')
        ?? 0;
    final int savedStreak = userData['streak'] as int?
        ?? prefs.getInt('streak')
        ?? 1;

    final int now  = DateTime.now().millisecondsSinceEpoch;
    final int diff = now - lastTime;

    if (lastTime == 0) {
      streak = 1;
    } else if (diff >= 86400000 && diff < 172800000) {
      streak = savedStreak + 1;
    } else if (diff >= 172800000) {
      streak = 1;
    } else {
      streak = savedStreak;
    }

    userData['streak']         = streak;
    userData['last_open_time'] = now;
    if (currentEmail.isNotEmpty) {
      users[currentEmail] = userData;
      await prefs.setString('users', jsonEncode(users));
    }
    await prefs.setInt('streak', streak);
    await prefs.setInt('last_open_time', now);

    if (mounted) {
      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showDailyRewardIfNeeded(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          MainHomePage(
            streak: () => streak,
            onNavigate: (i) => setState(() => _currentIndex = i),
            onDrawerChanged: (isOpen) {
              setState(() {
                _isDrawerOpen = isOpen;
              });
            },
          ),
          const InfoScreen(),
          const VideoScreen(),
          const QuizScreen(),
          const ProfilePage(),
        ],
      ),


      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isDrawerOpen
            ? const SizedBox.shrink()
            : buildNavBar(),
      ),
    );
  }

  Widget buildNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          navItem(Icons.home, 0),
          navItem(Icons.menu_book, 1),
          navItem(Icons.play_arrow, 2),
          navItem(Icons.quiz, 3),
          navItem(Icons.person, 4),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? primaryGreen : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 30,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}