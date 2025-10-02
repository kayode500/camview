import 'package:flutter/material.dart';
import '../model/movie.dart' as model;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trailer_player_screen.dart'; // Import the trailer player screen
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trailer_list_screen.dart';

// Add this function to fetch trailer list with details
Future<List<String>> fetchTrailerListWithDetails(String movieTitle) async {
  // This function returns a list of YouTube video IDs for the given movie title
  return await fetchTrailerVideoIds(movieTitle);
}

// Place your API key here
const String YOUTUBE_API_KEY = 'AIzaSyAAqHOs2UQWC9qV7P63fM01x0Os3oVrNtQ';

class MovieDetailsScreen extends StatelessWidget {
  final model.Movie movie;
  final String rating;
  final String genre;
  final String plot;
  final String cast;

  const MovieDetailsScreen({
    Key? key,
    required this.movie,
    required this.rating,
    required this.genre,
    required this.plot,
    required this.cast,
  }) : super(key: key);

  String getShortPlot(String plot) {
    final words = plot.split(' ');
    if (words.length <= 100) return plot;
    return words.take(100).join(' ') + '...';
  }

  List<String> getGenres() {
    return genre.split(',').map((g) => g.trim()).toList();
  }

  List<Map<String, String>> getCastList() {
    final names = cast.split(',').map((c) => c.trim()).toList();
    return names
        .map((name) => {
              'name': name,
              'image':
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random'
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final genres = getGenres();
    final castList = getCastList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Poster with play icon
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    movie.poster ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image,
                          color: Colors.white54, size: 48),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(Icons.play_circle_fill,
                            color: Colors.deepPurple, size: 40),
                        onPressed: () async {
                          var trailers =
                              await fetchTrailerListWithDetails(movie.title);
                          if (trailers.isEmpty &&
                              movie.poster != null &&
                              movie.poster!.isNotEmpty) {
                            final posterUri = Uri.tryParse(movie.poster!);
                            if (posterUri != null) {
                              final segments = posterUri.pathSegments;
                              if (segments.isNotEmpty) {
                                final fileName = segments.last.split('.').first;
                                if (fileName.isNotEmpty) {
                                  trailers = await fetchTrailerListWithDetails(
                                      fileName);
                                }
                              }
                            }
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrailerListScreen(
                                movieTitle: movie.title,
                                trailers: trailers
                                    .map((id) => TrailerInfo(
                                          videoId: id,
                                          title: '${movie.title} Trailer',
                                          thumbnailUrl:
                                              'https://img.youtube.com/vi/$id/0.jpg',
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 16,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            // Year | Type | Genres
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    movie.year,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    movie.type[0].toUpperCase() + movie.type.substring(1),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  ...genres.take(2).map((g) => Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          g,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      )),
                ],
              ),
            ),
            // Movie name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                movie.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // Rating with number and stars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  buildStarRating(rating),
                  const SizedBox(width: 8),
                  Text(
                    rating,
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            // Cast with rounded images
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cast & Crew',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: castList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final c = castList[index];
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(c['image']!),
                              backgroundColor: Colors.grey[800],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                c['name']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Details (plot)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getShortPlot(plot),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            // Similar movies (dummy horizontal list)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Similar Movies',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 180,
              child: FutureBuilder<List<model.Movie>>(
                future: fetchSimilarMovies(genre, movie.imdbID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No similar movies found.',
                            style: TextStyle(color: Colors.white70)));
                  }
                  final similarMovies = snapshot.data!;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: similarMovies.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final simMovie = similarMovies[index];
                      return GestureDetector(
                        onTap: () {
                          // Optionally, navigate to details of the similar movie
                        },
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  simMovie.poster!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white54, size: 48),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                simMovie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper for star rating
  Row buildStarRating(String rating) {
    List<Widget> stars = [];
    try {
      double ratingValue = double.tryParse(rating) ?? 0.0;
      int fullStars = (ratingValue / 2).floor();
      bool halfStar = (ratingValue / 2) - fullStars >= 0.5;
      for (int i = 0; i < 5; i++) {
        if (i < fullStars) {
          stars.add(const Icon(Icons.star, size: 18, color: Colors.orange));
        } else if (i == fullStars && halfStar) {
          stars
              .add(const Icon(Icons.star_half, size: 18, color: Colors.orange));
        } else {
          stars.add(
              const Icon(Icons.star_border, size: 18, color: Colors.orange));
        }
      }
    } catch (e) {
      stars.add(const Icon(Icons.star_border, size: 18, color: Colors.orange));
    }
    return Row(children: stars);
  }

  void playYouTubeVideo(String videoId) {
    // Implement the YouTube video playback logic here
    // This could navigate to a video player screen or open the video in a web view
  }
}

// Place this function outside the widget class, below MovieDetailsScreen
void navigateToMovieDetails(BuildContext context) {
  final sampleMovie = model.Movie(
    title: 'Movie Title',
    poster: 'https://via.placeholder.com/200x300',
    year: '2024',
    type: 'action',
    imdbID: 'tt1234567',
  );

  // Example data map for demonstration
  final data = {
    'imdbRating': '7.5',
    'Genre': 'Action, Adventure',
    'Plot': 'A thrilling adventure of a hero saving the world.',
    'Actors': 'John Doe, Jane Smith, Bob Johnson'
  };

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrailerPlayerScreen(
        youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        movieTitle: 'Movie Title',
      ),
    ),
  );
}

Future<List<model.Movie>> fetchSimilarMovies(
    String genre, String excludeImdbID) async {
  // Use the first genre for best results
  final mainGenre = genre.split(',').first.trim();
  final url =
      'https://www.omdbapi.com/?apikey=7fc7afd1&s=$mainGenre&type=movie';
  final response = await http.get(Uri.parse(url));
  print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['Search'] != null) {
      return (data['Search'] as List)
          .map((e) => model.Movie.fromJson(e))
          .where((movie) =>
                  movie.poster != null &&
                  movie.poster!.isNotEmpty &&
                  movie.poster != 'N/A' &&
                  movie.poster!.startsWith('http') &&
                  movie.imdbID != excludeImdbID // Exclude the current movie
              )
          .toList();
    }
  }
  return [];
}

Future<String?> fetchTrailerVideoId(String movieTitle) async {
  const apiKey = YOUTUBE_API_KEY;
  final query = Uri.encodeComponent('$movieTitle official trailer');
  final url =
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=15&q=$query&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['items'] != null && data['items'].isNotEmpty) {
      for (var item in data['items']) {
        final videoId = item['id']['videoId'];
        // Check if embeddable and public
        final detailsUrl =
            'https://www.googleapis.com/youtube/v3/videos?part=status&id=$videoId&key=$apiKey';
        final detailsResp = await http.get(Uri.parse(detailsUrl));
        if (detailsResp.statusCode == 200) {
          final details = json.decode(detailsResp.body);
          if (details['items'] != null && details['items'].isNotEmpty) {
            final status = details['items'][0]['status'];
            print('Trying videoId: $videoId, status: $status');
            if (status['embeddable'] == true &&
                status['privacyStatus'] == 'public') {
              return videoId;
            }
          }
        }
      }
    }
  }
  return null;
}

Future<List<String>> fetchTrailerVideoIds(String movieTitle) async {
  const apiKey = YOUTUBE_API_KEY;
  final query = Uri.encodeComponent('$movieTitle official trailer');
  final url =
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=$query&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  List<String> embeddableIds = [];
  String? fallbackVideoId;
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['items'] != null && data['items'].isNotEmpty) {
      for (var item in data['items']) {
        final videoId = item['id']['videoId'];
        fallbackVideoId ??= videoId; // Save the first videoId as fallback
        // Check if embeddable and public
        final detailsUrl =
            'https://www.googleapis.com/youtube/v3/videos?part=status&id=$videoId&key=$apiKey';
        final detailsResp = await http.get(Uri.parse(detailsUrl));
        if (detailsResp.statusCode == 200) {
          final details = json.decode(detailsResp.body);
          if (details['items'] != null && details['items'].isNotEmpty) {
            final status = details['items'][0]['status'];
            if (status['embeddable'] == true &&
                status['privacyStatus'] == 'public' &&
                (status['madeForKids'] == null ||
                    status['madeForKids'] == false)) {
              embeddableIds.add(videoId);
              if (embeddableIds.length >= 5) break; // Limit to 5
            }
          }
        }
      }
    }
  }
  if (embeddableIds.isNotEmpty) {
    return embeddableIds;
  } else if (fallbackVideoId != null) {
    return [fallbackVideoId];
  } else {
    return [];
  }
}

void playYouTubeTrailer(BuildContext context, String youtubeUrl) async {
  final uri = Uri.parse(youtubeUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch trailer')),
    );
  }
}

void showTrailerDialog(BuildContext context, String videoId) {
  if (videoId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid YouTube video ID')),
    );
    return;
  }
  final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
  playYouTubeTrailer(context, youtubeUrl);
}

void showTrailerPickerDialog(BuildContext context, List<String> videoIds) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.black,
      title:
          const Text('Select a Trailer', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        height: 120,
        width: 350,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: videoIds.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final videoId = videoIds[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close picker
                showTrailerDialog(
                    context, 'https://www.youtube.com/watch?v=$videoId');
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://img.youtube.com/vi/$videoId/0.jpg',
                      width: 120,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Trailer ${index + 1}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    ),
  );
}

class TrailerPlayerDialog extends StatefulWidget {
  final String videoId;
  const TrailerPlayerDialog({super.key, required this.videoId});

  @override
  State<TrailerPlayerDialog> createState() => _TrailerPlayerDialogState();
}

class _TrailerPlayerDialogState extends State<TrailerPlayerDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      contentPadding: EdgeInsets.zero,
      content: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}
