import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primaryGreen = Color(0xFF134D3F);
const bgColor = Color(0xFFEEF4F6);

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String title;
  final String lessonId;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required this.title,
    required this.lessonId,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController controller;

  double progress = 0;

  String get pKey => "progress_${widget.lessonId}";
  String get dKey => "done_${widget.lessonId}";
  String get countedKey => "counted_${widget.lessonId}";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(pKey) ?? 0;

    controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: true,
        useHybridComposition: true,
      ),
    )..addListener(_listener);

    Future.delayed(const Duration(seconds: 1), () {
      final dur = controller.metadata.duration.inSeconds;
      if (dur > 0 && saved > 0) {
        controller.seekTo(Duration(seconds: (saved * dur).toInt()));
      }
    });

    setState(() => progress = saved);
  }

  void _listener() async {
    if (!controller.value.isReady) return;

    final pos = controller.value.position.inSeconds;
    final dur = controller.metadata.duration.inSeconds;

    if (dur == 0) return;

    final p = pos / dur;

    if ((p - progress).abs() > 0.01) {
      setState(() => progress = p);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(pKey, p);

      if (p >= 0.9) {
        await prefs.setBool(dKey, true);

        final counted = prefs.getBool(countedKey) ?? false;

        if (!counted) {
          int total = prefs.getInt("totalVideos") ?? 0;
          await prefs.setInt("totalVideos", total + 1);
          await prefs.setBool(countedKey, true);
        }
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.title),
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: controller),
        builder: (context, player) {
          return Column(
            children: [
              player,
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: progress,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 5),
              Text("${(progress * 100).toInt()}% watched"),
            ],
          );
        },
      ),
    );
  }
}