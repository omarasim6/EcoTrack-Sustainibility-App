import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'video_player_page.dart';

const primaryGreen = Color(0xFF134D3F);
const bgColor = Color(0xFFEEF4F6);

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  int? _expandedIndex;

  final Map<String, String> _videoMap = const {
    'c1': 'G4H1N_yXBiA',
    'c2': 'oJAbATJCugs',
    'c3': '8q7_aV8eLUE',
    'w1': 'OasbYWF4_S8',
    'w2': 'ODni_Bey154',
    'w3': 'JcZcJ3yU4uE',
    'e1': '1kUE0BZtTRc',
    'e2': '1-g73ty9v04',
    'e3': 'zaXBVYr9Ij0',
    'wa1': '8sPjH6h2KfQ',
    'wa2': 'Om42Lppkd9w',
    'wa3': 'R1S3tP6pR1Q',
    'b1': '3pZ7h4k4Cq0',
    'b2': '3vijLre760w',
    'b3': 'FZ9j1zYF3X0',
    's1': '7V8oFI4GYMY',
    's2': '6jQ7y_qQYUA',
    's3': '8G7lZ0M0pJ8',
  };

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Climate',
      'emoji': '🌡️',
      'description': 'The crisis heating our planet',
      'lessons': [
        {'id': 'c1', 'title': 'Climate Change', 'duration': '12 min'},
        {'id': 'c2', 'title': 'Global Warming', 'duration': '9 min'},
        {'id': 'c3', 'title': 'Carbon Footprint', 'duration': '11 min'},
      ],
    },
    {
      'title': 'Waste',
      'emoji': '♻️',
      'description': 'Turning waste into opportunity',
      'lessons': [
        {'id': 'w1', 'title': 'Reduce Waste', 'duration': '8 min'},
        {'id': 'w2', 'title': 'Plastic Pollution', 'duration': '14 min'},
        {'id': 'w3', 'title': 'E-Waste Crisis', 'duration': '10 min'},
      ],
    },
    {
      'title': 'Energy',
      'emoji': '⚡',
      'description': 'Powering a sustainable future',
      'lessons': [
        {'id': 'e1', 'title': 'Renewable Energy', 'duration': '13 min'},
        {'id': 'e2', 'title': 'Energy Conservation', 'duration': '8 min'},
        {'id': 'e3', 'title': 'Fossil Fuels', 'duration': '11 min'},
      ],
    },
    {
      'title': 'Water',
      'emoji': '💧',
      'description': 'Our most precious resource',
      'lessons': [
        {'id': 'wa1', 'title': 'Save Water', 'duration': '7 min'},
        {'id': 'wa2', 'title': 'Water Pollution', 'duration': '10 min'},
        {'id': 'wa3', 'title': 'Clean Water Access', 'duration': '12 min'},
      ],
    },
    {
      'title': 'Biodiversity',
      'emoji': '🦋',
      'description': 'Protecting life on Earth',
      'lessons': [
        {'id': 'b1', 'title': 'Wildlife Protection', 'duration': '11 min'},
        {'id': 'b2', 'title': 'Deforestation', 'duration': '13 min'},
        {'id': 'b3', 'title': 'Endangered Species', 'duration': '9 min'},
      ],
    },
    {
      'title': 'Sustainability',
      'emoji': '🌱',
      'description': 'Living within our planet\'s limits',
      'lessons': [
        {'id': 's1', 'title': 'Sustainable Living', 'duration': '10 min'},
        {'id': 's2', 'title': 'Green Products', 'duration': '8 min'},
        {'id': 's3', 'title': 'Circular Economy', 'duration': '12 min'},
      ],
    },
  ];

  Future<Map<String, dynamic>> _getState(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'progress': prefs.getDouble('progress_$id') ?? 0.0,
      'done': prefs.getBool('done_$id') ?? false,
    };
  }

  void _openVideo(String id, String title) {
    final videoId = _videoMap[id];
    if (videoId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          videoId: videoId,
          title: title,
          lessonId: id,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Videos",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (_, i) => _buildCategory(i),
        ),
      ),
    );
  }

  Widget _buildCategory(int index) {
    final cat = _categories[index];
    final isOpen = _expandedIndex == index;
    final lessons = cat['lessons'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _expandedIndex = isOpen ? null : index),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isOpen ? 0 : 20),
                  bottomRight: Radius.circular(isOpen ? 0 : 20),
                ),
              ),
              child: Row(
                children: [
                  Text(cat['emoji'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['title'],
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          cat['description'],
                          style: GoogleFonts.dmSans(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${lessons.length} videos',
                    style: GoogleFonts.dmSans(
                        color: Colors.white, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: lessons.map<Widget>((lesson) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getState(lesson['id']),
                  builder: (_, snap) {
                    final progress =
                    (snap.data?['progress'] ?? 0.0) as double;
                    final done =
                    (snap.data?['done'] ?? false) as bool;

                    return _VideoLessonTile(
                      lesson: lesson,
                      progress: progress,
                      done: done,
                      onTap: () => _openVideo(
                        lesson['id'],
                        lesson['title'],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            secondChild: const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _VideoLessonTile extends StatelessWidget {
  final Map lesson;
  final double progress;
  final bool done;
  final VoidCallback onTap;

  const _VideoLessonTile({
    required this.lesson,
    required this.progress,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: done
                        ? Colors.green.withOpacity(0.1)
                        : primaryGreen.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_filled_rounded,
                    size: 28,
                    color: done ? Colors.green : primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lesson['title'],
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: primaryGreen,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(
                done ? Colors.green : primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}