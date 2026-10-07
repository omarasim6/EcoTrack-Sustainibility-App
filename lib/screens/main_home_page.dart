import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';

const primaryGreen = Color(0xFF134D3F);
const bgColor = Color(0xFFEEF4F6);

class MainHomePage extends StatefulWidget {
  final int Function() streak;
  final Function(int index) onNavigate;
  final Function(bool isOpen) onDrawerChanged;

  const MainHomePage({
    super.key,
    required this.streak,
    required this.onNavigate,
    required this.onDrawerChanged,
  });

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage>
    with WidgetsBindingObserver {
  String _name = '';
  int _totalVideos = 0;
  int _totalQuiz = 0;
  int _totalCoins = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
    _loadStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadStats();
  }

  @override
  void didUpdateWidget(MainHomePage old) {
    super.didUpdateWidget(old);
    _loadStats();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUser') ?? '';
    Map<String, dynamic> users = {};
    try {
      final s = prefs.getString('users');
      if (s != null && s.isNotEmpty) users = jsonDecode(s);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _name = users[email]?['name'] ?? 'Eco Warrior';
      });
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _totalVideos = prefs.getInt('totalVideos') ?? 0;
        _totalQuiz = prefs.getInt('totalQuiz') ?? 0;
        _totalCoins = prefs.getInt('totalCoins') ?? 0;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      onDrawerChanged: widget.onDrawerChanged,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroBanner(name: _name, streak: widget.streak()),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      child: _StatCard(
                        emoji: '🔥',
                        label: 'Streak',
                        value: '${widget.streak()}d',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 70,
                      child: _StatCard(
                        emoji: '🧠',
                        label: 'Quizzes',
                        value: '$_totalQuiz',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 70,
                      child: _StatCard(
                        emoji: '🎥',
                        label: 'Videos',
                        value: '$_totalVideos',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Explore',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryGreen,
                    )),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _simpleCard(
                      title: 'Learn',
                      subtitle:
                      'Explore sustainability topics — climate, waste, energy & more',
                      emoji: '📗',
                      onTap: () => widget.onNavigate(1),
                    ),
                    const SizedBox(height: 10),

                    _simpleCard(
                      title: 'Watch',
                      subtitle:
                      'Video documentaries on real-world sustainability challenges',
                      emoji: '🎬',
                      onTap: () => widget.onNavigate(2),
                    ),
                    const SizedBox(height: 10),

                    _simpleCard(
                      title: 'Quiz',
                      subtitle:
                      'Test your eco-knowledge with interactive challenges',
                      emoji: '🎯',
                      onTap: () => widget.onNavigate(3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              _EcoFactStrip(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(
            'EcoTrack',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: primaryGreen,
            ),
          ),
        ],
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: const Icon(Icons.menu_rounded,
                color: primaryGreen, size: 18),
          ),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => widget.onNavigate(4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: primaryGreen.withOpacity(0.3), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDrawer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      child: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.only(top: 56, bottom: 28, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(_name,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DrawerStat('🔥', '${widget.streak()}d'),
                      const SizedBox(width: 20),
                      _DrawerStat('🧠', '$_totalQuiz'),
                      const SizedBox(width: 20),
                      _DrawerStat('🎥', '$_totalVideos'),
                      const SizedBox(width: 20),
                      _DrawerStat('🪙', '$_totalCoins'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _DrawerItem(Icons.home_rounded, 'Home', () {
              Navigator.pop(context);
              widget.onNavigate(0);
            }),
            _DrawerItem(Icons.menu_book_rounded, 'Learn', () {
              Navigator.pop(context);
              widget.onNavigate(1);
            }),
            _DrawerItem(Icons.play_circle_rounded, 'Videos', () {
              Navigator.pop(context);
              widget.onNavigate(2);
            }),
            _DrawerItem(Icons.quiz_rounded, 'Quiz', () {
              Navigator.pop(context);
              widget.onNavigate(3);
            }),
            _DrawerItem(Icons.person_rounded, 'Profile', () {
              Navigator.pop(context);
              widget.onNavigate(4);
            }),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),

            _DrawerItem(
              Icons.logout_rounded,
              'Logout',
                  () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (r) => false,
                );
              },
              danger: true,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String name;
  final int streak;
  const _HeroBanner({required this.name, required this.streak});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = name.split(' ').first;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: GoogleFonts.dmSans(
                        color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  firstName.isNotEmpty ? firstName : 'Eco Warrior',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '🌱 Making a difference every day',
                    style: GoogleFonts.dmSans(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 36)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.emoji,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final LinearGradient gradient;
  final String emoji;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.gradient,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(tag,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        )),
                  ),
                  const SizedBox(height: 10),
                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: GoogleFonts.dmSans(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EcoFactStrip extends StatefulWidget {
  const _EcoFactStrip();

  @override
  State<_EcoFactStrip> createState() => _EcoFactStripState();
}

class _EcoFactStripState extends State<_EcoFactStrip> {
  final List<Map<String, String>> _facts = const [
    {
      'emoji': '🌊',
      'fact':
      'The oceans absorb 30% of the CO₂ we produce, causing ocean acidification.'
    },
    {
      'emoji': '🌳',
      'fact':
      'A single tree can absorb up to 48 lbs of CO₂ per year over its lifetime.'
    },
    {
      'emoji': '♻️',
      'fact':
      'Recycling one aluminium can saves enough energy to run a TV for 3 hours.'
    },
    {
      'emoji': '💧',
      'fact':
      'Only 3% of Earth\'s water is fresh; less than 1% is readily accessible.'
    },
    {
      'emoji': '🌱',
      'fact':
      'Switching to a plant-based diet can reduce your carbon footprint by up to 73%.'
    },
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyFact();
  }

  Future<void> _loadDailyFact() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now().toString().substring(0, 10);
    final savedDate = prefs.getString('factDate');

    if (savedDate == today) {
      _index = prefs.getInt('factIndex') ?? 0;
    } else {
      _index = DateTime.now().day % _facts.length;
      await prefs.setString('factDate', today);
      await prefs.setInt('factIndex', _index);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final f = _facts[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Did You Know?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primaryGreen,
              )),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: primaryGreen.withOpacity(0.3), width: 1),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Text(f['emoji']!, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    f['fact']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerStat extends StatelessWidget {
  final String emoji;
  final String value;
  const _DrawerStat(this.emoji, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;
  const _DrawerItem(this.icon, this.title, this.onTap, {this.danger = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: danger
              ? Colors.red.withOpacity(0.08)
              : primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: danger ? Colors.red : primaryGreen, size: 18),
      ),
      title: Text(title,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: danger ? Colors.red : primaryGreen,
          )),
      trailing: danger
          ? null
          : Icon(Icons.chevron_right_rounded,
          color: Colors.black26, size: 18),
      onTap: onTap,
    );
  }
}
Widget _simpleCard({
  required String title,
  required String subtitle,
  required String emoji,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: primaryGreen.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.black38),
        ],
      ),
    ),
  );
}