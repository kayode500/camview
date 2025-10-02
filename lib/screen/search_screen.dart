import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart'; // For Movie class and fetchMoviesWithFilters

// Dummy implementation of fetchMoviesWithFilters if not imported from home_page.dart
Future<List<Movie>> fetchMoviesWithFilters({
  String? title,
  String? year,
  String? category,
  String? country,
}) async {
  // TODO: Replace this with your actual fetching logic or remove if already imported.
  await Future.delayed(const Duration(milliseconds: 500));
  // Return dummy data for demonstration
  return [
    Movie(
      title: title ?? 'Sample Movie',
      year: year ?? '2023',
      type: category ?? 'Movie',
      poster: 'https://via.placeholder.com/150',
      imdbID: 'tt1234567',
    ),
  ];
}

// If Movie is not exported from home_page.dart, define it here or ensure the import is correct.
class Movie {
  final String title;
  final String year;
  final String type;
  final String poster;
  final String imdbID;
  Movie({
    required this.title,
    required this.year,
    required this.type,
    required this.poster,
    required this.imdbID,
  });
}

class SearchScreen extends StatefulWidget {
  final String query;
  const SearchScreen({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  Timer? _debounce;
  List<Movie> _suggestions = [];
  Future<List<Movie>>? _futureResults;
  String _searchQuery = '';

  Future<String> fetchMovieRating(String imdbID) async {
    // TODO: Replace this with your actual implementation.
    // For now, returns a dummy rating.
    await Future.delayed(const Duration(milliseconds: 300));
    return 'N/A';
  }

  @override
  void initState() {
    super.initState();
    String initial = widget.query;
    if (initial.isEmpty) {
      // Optionally load from storage or keep empty
      // initial = 'last search'; // if you store it
    }
    _controller = TextEditingController(text: initial);
    _searchQuery = initial;
    if (_searchQuery.isNotEmpty) {
      _futureResults = fetchMoviesWithFilters(title: _searchQuery);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isNotEmpty) {
        final suggestions = await fetchMoviesWithFilters(title: query);
        setState(() {
          _suggestions = suggestions;
        });
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  void _onSuggestionTap(String title) {
    setState(() {
      _controller.text = title;
      _searchQuery = title;
      _suggestions = [];
      _futureResults = fetchMoviesWithFilters(title: title);
    });
    FocusScope.of(context).unfocus();
  }

  void _onSubmitted(String query) {
    setState(() {
      _searchQuery = query;
      _suggestions = [];
      _futureResults = fetchMoviesWithFilters(title: query);
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Name, genre, actor, year',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _onSubmitted,
            ),
          ),
          if (_suggestions.isNotEmpty)
            Material(
              elevation: 4,
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length > 6 ? 6 : _suggestions.length,
                itemBuilder: (context, index) {
                  final movie = _suggestions[index];
                  return ListTile(
                    title: Text(movie.title),
                    onTap: () => _onSuggestionTap(movie.title),
                  );
                },
              ),
            ),
          if (_futureResults != null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: _futureResults == null
                ? const Center(child: Text('Type to search for movies.'))
                : FutureBuilder<List<Movie>>(
                    future: _futureResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No movies found.'));
                      }
                      final movies = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  movie.poster,
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: double.infinity,
                                    height: 140,
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white54, size: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Year: ${movie.year}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Type: ${movie.type}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              FutureBuilder<String>(
                                future: fetchMovieRating(movie.imdbID),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    );
                                  }
                                  final rating = snapshot.data ?? 'N/A';
                                  return Text(
                                    'Rating: $rating',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.orange),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Movie App'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                Tab(icon: Icon(Icons.search), text: 'Search'),
                Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Center(child: Text('Home')),
              SearchScreen(query: ''),
              Center(child: Text('Favorites')),
              Center(child: Text('Profile')),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MainApp());
}
