import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MoviePlayer extends StatefulWidget {
  final String videoUrl; // Can be network or asset video
  const MoviePlayer({super.key, required this.videoUrl});

  @override
  State<MoviePlayer> createState() => _MoviePlayerState();
}

class _MoviePlayerState extends State<MoviePlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}

Future<String?> fetchTrailerVideoId(String movieName) async {
  final yt = YoutubeExplode();
  try {
    final searchQuery = '$movieName official trailer 2025';
    final searchResults = await yt.search.search(searchQuery);
    final video = searchResults
        .whereType<Video>()
        .cast<Video?>()
        .firstWhere((v) => v != null, orElse: () => null);
    return video?.id.value;
  } finally {
    yt.close();
  }
}
