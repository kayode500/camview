import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrailerPlayerScreen extends StatelessWidget {
  final String youtubeUrl;
  final String movieTitle;

  const TrailerPlayerScreen({
    super.key,
    required this.youtubeUrl,
    required this.movieTitle,
  });

  Future<void> _launchTrailer(BuildContext context) async {
    final uri = Uri.parse(youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch trailer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_fill, size: 40),
          label: const Text('Play Trailer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () => _launchTrailer(context),
        ),
      ),
    );
  }
}