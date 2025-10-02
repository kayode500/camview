import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrailerInfo {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  TrailerInfo(
      {required this.videoId, required this.title, required this.thumbnailUrl});
}

class TrailerListScreen extends StatelessWidget {
  final String movieTitle;
  final List<TrailerInfo> trailers;

  const TrailerListScreen({
    Key? key,
    required this.movieTitle,
    required this.trailers,
  }) : super(key: key);

  void playYouTubeTrailer(BuildContext context, String videoId) async {
    final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
    final uri = Uri.parse(youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch trailer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trailers for "$movieTitle"'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: trailers.isEmpty
          ? const Center(
              child: Text('No trailers found.',
                  style: TextStyle(color: Colors.white70)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trailers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final trailer = trailers[index];
                return GestureDetector(
                  onTap: () => playYouTubeTrailer(context, trailer.videoId),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Image.network(
                            trailer.thumbnailUrl.isNotEmpty
                                ? trailer.thumbnailUrl
                                : 'https://img.youtube.com/vi/${trailer.videoId}/0.jpg',
                            width: 120,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            trailer.title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.play_arrow,
                            color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Future<List<TrailerInfo>> fetchTrailerListWithDetails(String movieTitle) async {
  const apiKey = 'AIzaSyAAqHOs2UQWC9qV7P63fM01x0Os3oVrNtQ';
  final query = Uri.encodeComponent('$movieTitle official trailer');
  final url =
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=$query&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  List<TrailerInfo> trailers = [];
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['items'] != null && data['items'].isNotEmpty) {
      for (var item in data['items']) {
        final videoId = item['id']['videoId'];
        final title = item['snippet']['title'] ?? 'Trailer';
        final thumbnailUrl = item['snippet']['thumbnails']?['high']?['url'] ??
            item['snippet']['thumbnails']?['default']?['url'] ??
            '';
        trailers.add(TrailerInfo(
            videoId: videoId, title: title, thumbnailUrl: thumbnailUrl));
      }
    }
  }
  return trailers;
}
