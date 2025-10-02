import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MovieVideoPlayer extends StatefulWidget {
  final String url;
  const MovieVideoPlayer({super.key, required this.url});

  @override
  State<MovieVideoPlayer> createState() => _MovieVideoPlayerState();
}

class _MovieVideoPlayerState extends State<MovieVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

Future<String?> fetchTrailerVideoId(String movieName) async {
  final yt = YoutubeExplode();
  final searchQuery = '$movieName official trailer 2025';
  final searchResults = await yt.search.search(searchQuery);
  final video = searchResults.whereType<Video>().cast<Video?>().firstOrNull;
  yt.close();
  return video?.id.value;
}
