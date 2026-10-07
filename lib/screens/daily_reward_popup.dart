import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primaryGreen = Color(0xFF134D3F);

const List<int> _dayRewards = [10, 20, 30, 50, 75, 100, 150];

Future<void> showDailyRewardIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();


  final currentEmail = prefs.getString('currentUser') ?? '';
  if (currentEmail.isEmpty) return;


  Map<String, dynamic> users = {};
  try {
    final raw = prefs.getString('users');
    if (raw != null && raw.isNotEmpty) users = jsonDecode(raw);
  } catch (_) {}

  final userData = Map<String, dynamic>.from(
    (users[currentEmail] as Map<String, dynamic>?) ?? {},
  );


  final today = _todayKey();
  final lastClaimed = userData['last_reward_date'] as String? ?? '';

  if (lastClaimed == today) return;

  final streak = prefs.getInt('streak') ?? 1;
  final dayIndex = (streak - 1) % _dayRewards.length;
  final coinsEarned = _dayRewards[dayIndex];


  final currentCoins = userData['totalCoins'] as int? ?? 0;
  final newTotal = currentCoins + coinsEarned;


  userData['totalCoins']       = newTotal;
  userData['last_reward_date'] = today;
  users[currentEmail]          = userData;

  await prefs.setString('users', jsonEncode(users));

  await prefs.setInt('totalCoins', newTotal);

  if (!context.mounted) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    pageBuilder: (_, __, ___) => _DailyRewardDialog(
      streak: streak,
      dayIndex: dayIndex,
      coinsEarned: coinsEarned,
      totalCoins: newTotal,
    ),
  );
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month}-${now.day}';
}

class _DailyRewardDialog extends StatefulWidget {
  final int streak;
  final int dayIndex;
  final int coinsEarned;
  final int totalCoins;

  const _DailyRewardDialog({
    required this.streak,
    required this.dayIndex,
    required this.coinsEarned,
    required this.totalCoins,
  });

  @override
  State<_DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<_DailyRewardDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _coinCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _coinAnim;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.elasticOut,
    );

    _coinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _coinAnim = CurvedAnimation(parent: _coinCtrl, curve: Curves.easeOut);

    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), _coinCtrl.forward);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _coinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
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
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [

                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🪙',
                                style: TextStyle(fontSize: 42)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Daily Reward!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🔥 Day ${widget.streak} Streak',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final reward = _dayRewards[i];
                      final isToday = i == widget.dayIndex;
                      final isPast = i < widget.dayIndex;

                      return _DayChip(
                        day: i + 1,
                        coins: reward,
                        isToday: isToday,
                        isPast: isPast,
                      );
                    }),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Text(
                        'You earned',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      AnimatedBuilder(
                        animation: _coinAnim,
                        builder: (_, __) {
                          final displayed =
                          (widget.coinsEarned * _coinAnim.value).round();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🪙',
                                  style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 8),
                              Text(
                                '+$displayed coins',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ${widget.totalCoins} coins',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Claim Reward 🎁',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _DayChip extends StatelessWidget {
  final int day;
  final int coins;
  final bool isToday;
  final bool isPast;

  const _DayChip({
    required this.day,
    required this.coins,
    required this.isToday,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    if (isToday) {
      bg = primaryGreen;
      border = primaryGreen;
      textColor = Colors.white;
    } else if (isPast) {
      bg = Colors.green.shade50;
      border = Colors.green.shade300;
      textColor = Colors.green.shade700;
    } else {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      textColor = Colors.grey;
    }

    return Container(
      width: 36,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'D$day',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            isPast ? '✓' : (isToday ? '🪙' : '$coins'),
            style: TextStyle(
              fontSize: isToday || isPast ? 12 : 9,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}