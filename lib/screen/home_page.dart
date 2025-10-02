import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'movie_details_screen.dart';
import '../model/movie.dart' as model;
import 'package:camview/model/session.dart';

// SearchScreen widget moved to top-level for proper definition
class SearchScreen extends StatefulWidget {
  final String title;
  final String year;
  final String category;
  final String country;
  final List<model.Movie> favoriteMovies;
  final void Function(model.Movie) onToggleFavorite;

  const SearchScreen({
    Key? key,
    required this.title,
    required this.year,
    required this.category,
    required this.country,
    this.favoriteMovies = const [],
    this.onToggleFavorite = _noopToggleFavorite,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

void _noopToggleFavorite(model.Movie movie) {}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  late Future<List<model.Movie>> _futureResults;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
    _futureResults = fetchMoviesWithFilters(
      title: widget.title,
      year: widget.year,
      category: widget.category,
      country: widget.country,
    );
  }

  void _onSubmitted(String query) {
    setState(() {
      _futureResults = fetchMoviesWithFilters(
        title: query,
        year: '',
        category: '',
        country: '',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white70 : Colors.black54;
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results', style: TextStyle(color: textColor)),
        backgroundColor: isDark ? Colors.black : Colors.deepPurple,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Name, genre, actor, year',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: hintColor),
                hintStyle: TextStyle(color: hintColor),
              ),
              onSubmitted: _onSubmitted,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<model.Movie>>(
              future: _futureResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No movies found.',
                        style: TextStyle(color: hintColor)),
                  );
                }
                final movies = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        GestureDetector(
                          onTap: () async {
                            // Fetch full details from OMDb
                            final url =
                                'https://www.omdbapi.com/?apikey=7fc7afd1&i=${movie.imdbID}&plot=full';
                            final response = await http.get(Uri.parse(url));
                            if (response.statusCode == 200) {
                              final data = json.decode(response.body);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsScreen(
                                    movie: movie,
                                    rating: data['imdbRating'] ?? 'N/A',
                                    genre: data['Genre'] ?? 'N/A',
                                    plot: data['Plot'] ?? 'N/A',
                                    cast: data['Actors'] ?? 'N/A',
                                  ),
                                ),
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.poster ?? '',
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: double.infinity,
                                height: 140,
                                color: Colors.grey[900],
                                child: Icon(Icons.broken_image,
                                    color: hintColor, size: 32),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        Text(
                          'Year: ${movie.year}',
                          style: TextStyle(fontSize: 12, color: hintColor),
                        ),
                        Text(
                          'Type: ${movie.type}',
                          style: TextStyle(fontSize: 12, color: hintColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                return Row(
                                  children: [
                                    buildStarRating(rating),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.orange),
                                    ),
                                  ],
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                widget.favoriteMovies.any(
                                        (fav) => fav.imdbID == movie.imdbID)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                widget.onToggleFavorite(movie);
                                setState(() {});
                              },
                              tooltip: 'Add to Favorites',
                            ),
                          ],
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

final List<String> categories = [
  'Trending',
  'Action',
  'Comedy',
  'Horror',
  'Romance',
  'Sci-Fi',
];
// Removed Movie class definition from here.
// Import the shared Movie model instead.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDarkMode = false;
  bool showSearchInput = false;
  final TextEditingController _searchController = TextEditingController();
  List<model.Movie> favoriteMovies = [];
  int _selectedIndex = 0;
  int _randomMoviesPage = 1 + Random().nextInt(10);

  // Replace these with your actual widgets/pages
  List<Widget> get _pages => [
        // Home tab: your current homepage content
        Builder(
          builder: (context) {
            final isDark = isDarkMode;
            final textColor = isDark ? Colors.white : Colors.black;
            final hintColor = isDark ? Colors.white70 : Colors.black54;
            return SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (showSearchInput) {
                    setState(() {
                      showSearchInput = false;
                      FocusScope.of(context).unfocus();
                    });
                  }
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showSearchInput)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Name, genre, actor, year',
                                border: const OutlineInputBorder(),
                                prefixIcon:
                                    Icon(Icons.search, color: hintColor),
                                hintStyle: TextStyle(color: hintColor),
                              ),
                              onSubmitted: (query) {
                                setState(() {
                                  showSearchInput = false;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchScreen(
                                      title: query,
                                      year: '',
                                      category: '',
                                      country: '',
                                      favoriteMovies: favoriteMovies,
                                      onToggleFavorite: (movie) {
                                        setState(() {
                                          if (favoriteMovies.any((fav) =>
                                              fav.imdbID == movie.imdbID)) {
                                            favoriteMovies.removeWhere((fav) =>
                                                fav.imdbID == movie.imdbID);
                                          } else {
                                            favoriteMovies.add(movie);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        // Banner Carousel for Latest Movies (from API)
                        FutureBuilder<List<model.Movie>>(
                          future: fetchMovies(DateTime.now().year.toString()),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                height: 200,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final movies = snapshot.data!;
                            if (movies.isEmpty) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                    child: Text('No latest movies found',
                                        style: TextStyle(color: Colors.white))),
                              );
                            }
                            final width = MediaQuery.of(context).size.width;
                            return CarouselSlider(
                              options: CarouselOptions(
                                height: 200,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 1.0,
                              ),
                              items: movies.map((movie) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        movie.poster!,
                                        width: width,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: width,
                                          height: 200,
                                          color: Colors.grey[900],
                                          child: Icon(Icons.broken_image,
                                              color: hintColor, size: 48),
                                        ),
                                      ),
                                    ),
                                    // "Coming Soon" label at top left
                                    Positioned(
                                      left: 16,
                                      top: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Coming Soon',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Movie title at bottom left
                                    Positioned(
                                      left: 16,
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          movie.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // --- Movie Recommendations Section (Categories) ---
                        Text(
                          'Movie Recommendations',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MovieRecommendations(
                          favoriteMovies: favoriteMovies,
                          onToggleFavorite: (movie) {
                            setState(() {
                              if (favoriteMovies
                                  .any((fav) => fav.imdbID == movie.imdbID)) {
                                favoriteMovies.removeWhere(
                                    (fav) => fav.imdbID == movie.imdbID);
                              } else {
                                favoriteMovies.add(movie);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // --- Random Movies Section ---
                        Text(
                          'Random Movies',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.refresh, color: textColor),
                              tooltip: 'Refresh',
                              onPressed: _refreshRandomMovies,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 420,
                          child: FutureBuilder<List<model.Movie>>(
                            future: fetchMoviesWithFilters(
                              title: 'movie',
                              maxPages: 1,
                              page: _randomMoviesPage,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No movies found.',
                                    style: TextStyle(color: hintColor),
                                  ),
                                );
                              }
                              final movies = snapshot.data!.take(12).toList();
                              return GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.67,
                                ),
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final url =
                                              'https://www.omdbapi.com/?apikey=7fc7afd1&i=${movie.imdbID}&plot=full';
                                          final response =
                                              await http.get(Uri.parse(url));
                                          if (response.statusCode == 200) {
                                            final data =
                                                json.decode(response.body);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MovieDetailsScreen(
                                                  movie: movie,
                                                  rating: data['imdbRating'] ??
                                                      'N/A',
                                                  genre: data['Genre'] ?? 'N/A',
                                                  plot: data['Plot'] ?? 'N/A',
                                                  cast: data['Actors'] ?? 'N/A',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            movie.poster!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: Colors.grey[800],
                                              child: Icon(Icons.broken_image,
                                                  color: hintColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Favorite icon button
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: IconButton(
                                          icon: Icon(
                                            favoriteMovies.any((fav) =>
                                                    fav.imdbID == movie.imdbID)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (favoriteMovies.any((fav) =>
                                                  fav.imdbID == movie.imdbID)) {
                                                favoriteMovies.removeWhere(
                                                    (fav) =>
                                                        fav.imdbID ==
                                                        movie.imdbID);
                                              } else {
                                                favoriteMovies.add(movie);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
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
                ),
              ),
            );
          },
        ),
        // Explore tab
        ExploreScreen(
          favoriteMovies: favoriteMovies,
          onToggleFavorite: (movie) {
            setState(() {
              if (favoriteMovies.any((fav) => fav.imdbID == movie.imdbID)) {
                favoriteMovies.removeWhere((fav) => fav.imdbID == movie.imdbID);
              } else {
                favoriteMovies.add(movie);
              }
            });
          },
        ),
        // Favorites tab
        FavoriteScreen(
          favoriteMovies: favoriteMovies,
          onRemoveFavorite: (movie) {
            setState(() {
              favoriteMovies.removeWhere((fav) => fav.imdbID == movie.imdbID);
            });
          },
        ),
        // Profile tab
        const ProfilePage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showFavorites(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favorite Movies'),
        content: SizedBox(
          width: double.maxFinite,
          child: favoriteMovies.isEmpty
              ? const Text('No favorites yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = favoriteMovies[index];
                    return ListTile(
                      leading: Image.network(
                        movie.poster!,
                        width: 40,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                      title: Text(movie.title),
                      subtitle: Text('Year: ${movie.year}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            favoriteMovies.removeAt(index);
                          });
                          Navigator.of(context).pop();
                          _showFavorites(context); // Refresh dialog
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _refreshRandomMovies() {
    setState(() {
      _randomMoviesPage = 1 + Random().nextInt(10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final textColor = isDark ? Colors.deepPurple : Colors.deepPurple;
    final hintColor = isDark ? Colors.white70 : Colors.black54;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      drawer: Drawer(
        backgroundColor: isDark ? Colors.black : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black
                    : Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person,
                        size: 40,
                        color: (isDark ||
                                Theme.of(context).colorScheme.primary ==
                                    Colors.deepPurple)
                            ? Colors.white
                            : Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser?.userName ?? 'Guest',
                    style: TextStyle(
                      color: (isDark ||
                              Theme.of(context).colorScheme.primary ==
                                  Colors.deepPurple)
                          ? Colors.white
                          : Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    currentUser?.userEmail ?? '',
                    style: TextStyle(
                      color: (isDark ||
                              Theme.of(context).colorScheme.primary ==
                                  Colors.deepPurple)
                          ? Colors.white
                          : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              tileColor: isDark ? Colors.black : Colors.white,
              leading: const Icon(Icons.settings, color: Colors.deepPurple),
              title: const Text('Settings',
                  style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Container(
              color: isDark ? Colors.black : Colors.white,
              child: SwitchListTile(
                secondary:
                    const Icon(Icons.light_mode, color: Colors.deepPurple),
                title: const Text('Theme',
                    style: TextStyle(color: Colors.deepPurple)),
                value: isDark,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
                activeColor: Colors.deepPurple,
                inactiveThumbColor: Colors.deepPurple,
                inactiveTrackColor: Colors.deepPurpleAccent,
              ),
            ),
            ListTile(
              tileColor: isDark ? Colors.black : Colors.white,
              leading: const Icon(Icons.info_outline, color: Colors.deepPurple),
              title: const Text('About Camview',
                  style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Camview',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 Camview',
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Camview is a modern movie streaming app crafted with care by Kayode, Owolabil, and Sarah.\n\n'
                        'Discover trending films, search by your favorite genres, and save movies you love.\n\n'
                        'Thank you for using Camview!',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
            ListTile(
              tileColor: isDark ? Colors.black : Colors.white,
              leading: const Icon(Icons.logout, color: Colors.deepPurple),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor:
            isDark ? Colors.black : Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: (isDark ||
                        Theme.of(context).colorScheme.primary ==
                            Colors.deepPurple)
                    ? Colors.white
                    : Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Camview',
          style: TextStyle(
            color: (isDark ||
                    Theme.of(context).colorScheme.primary == Colors.deepPurple)
                ? Colors.white
                : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          if (!showSearchInput)
            IconButton(
              icon: Icon(Icons.search,
                  color: (isDark ||
                          Theme.of(context).colorScheme.primary ==
                              Colors.deepPurple)
                      ? Colors.white
                      : Colors.white),
              onPressed: () {
                setState(() {
                  showSearchInput = true;
                });
              },
            ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.favorite,
                    color: (isDark ||
                            Theme.of(context).colorScheme.primary ==
                                Colors.deepPurple)
                        ? Colors.white
                        : Colors.white),
                onPressed: () {
                  _showFavorites(context);
                },
              ),
              if (favoriteMovies.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${favoriteMovies.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            isDark ? Colors.black : Theme.of(context).colorScheme.primary,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    String selectedYear = '';
    String selectedCategory = '';
    String selectedCountry = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Search & Filter',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Movie Title',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => selectedYear = v,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => selectedCategory = v,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => selectedCountry = v,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          title: searchController.text,
                          year: selectedYear,
                          category: selectedCategory,
                          country: selectedCountry,
                        ),
                      ),
                    );
                  },
                  child: const Text('Search',
                      style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- OMDb API Section ---

Future<List<model.Movie>> fetchMovies(String category, {int page = 1}) async {
  String searchQuery;
  if (category == 'Trending') {
    searchQuery = '2024';
  } else {
    searchQuery = category;
  }
  final url =
      'https://www.omdbapi.com/?apikey=7fc7afd1&s=$searchQuery&type=movie&page=$page';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['Search'] != null) {
      return (data['Search'] as List)
          .map((e) => model.Movie.fromJson(e))
          .where((movie) =>
              movie.poster != null &&
              movie.poster!.isNotEmpty &&
              movie.poster != 'N/A' &&
              movie.poster!.startsWith('http'))
          .toList();
    }
  }
  return [];
}

Future<String> fetchMovieRating(String imdbID) async {
  final url = 'https://www.omdbapi.com/?apikey=7fc7afd1&i=$imdbID';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['imdbRating'] ?? 'N/A';
  }
  return 'N/A';
}

Future<List<model.Movie>> fetchMoviesWithFilters({
  String? title,
  String? year,
  String? category,
  String? country,
  int maxPages = 1,
  int page = 1, // <-- add this
}) async {
  List<model.Movie> allMovies = [];
  for (int p = page; p < page + maxPages; p++) {
    String url = 'https://www.omdbapi.com/?apikey=7fc7afd1&s=${title ?? ''}';
    if (year != null && year.isNotEmpty) url += '&y=$year';
    if (category != null && category.isNotEmpty) url += '&type=movie';
    if (country != null && country.isNotEmpty) url += '&country=$country';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Search'] != null) {
        allMovies.addAll((data['Search'] as List)
            .map((e) => model.Movie.fromJson(e))
            .where((movie) =>
                movie.poster != null &&
                movie.poster!.isNotEmpty &&
                movie.poster != 'N/A' &&
                movie.poster!.startsWith('http')));
      } else {
        break; // No more results
      }
    }
  }
  return allMovies;
}

// --- Movie Recommendations Widget ---

class MovieRecommendations extends StatefulWidget {
  final List<model.Movie> favoriteMovies;
  final void Function(model.Movie) onToggleFavorite;

  const MovieRecommendations({
    super.key,
    required this.favoriteMovies,
    required this.onToggleFavorite,
  });

  @override
  State<MovieRecommendations> createState() => _MovieRecommendationsState();
}

class _MovieRecommendationsState extends State<MovieRecommendations> {
  final Map<String, List<model.Movie>> _categoryMovies = {};
  final Map<String, int> _categoryPages = {};
  final Map<String, bool> _isLoadingMore = {};

  @override
  void initState() {
    super.initState();
    // Initialize each category with the first page of movies
    for (var cat in categories) {
      _fetchMoviesForCategory(cat, 1);
    }
  }

  Future<void> _fetchMoviesForCategory(String category, int page) async {
    setState(() {
      _isLoadingMore[category] = true;
    });
    final movies = await fetchMovies(category, page: page);
    setState(() {
      _categoryMovies[category] = [
        ...(_categoryMovies[category] ?? []),
        ...movies
      ];
      _categoryPages[category] = page;
      _isLoadingMore[category] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get isDarkMode from HomePage
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    final isDark = homeState?.isDarkMode ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((cat) {
        final movies = _categoryMovies[cat] ?? [];
        final isLoading = _isLoadingMore[cat] ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: movies.length + 1, // +1 for Load More
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index < movies.length) {
                    final movie = movies[index];
                    final isFav = widget.favoriteMovies
                        .any((fav) => fav.imdbID == movie.imdbID);
                    return GestureDetector(
                      onTap: () async {
                        final url =
                            'https://www.omdbapi.com/?apikey=7fc7afd1&i=${movie.imdbID}&plot=full';
                        final response = await http.get(Uri.parse(url));
                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(
                                movie: movie,
                                rating: data['imdbRating'] ?? 'N/A',
                                genre: data['Genre'] ?? 'N/A',
                                plot: data['Plot'] ?? 'N/A',
                                cast: data['Actors'] ?? 'N/A',
                              ),
                            ),
                          );
                        }
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.poster ?? '',
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[800],
                                child: Icon(Icons.broken_image,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                widget.onToggleFavorite(movie);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Load More slider card
                    return SizedBox(
                      width: 120,
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : IconButton(
                                icon: Icon(Icons.refresh,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                                onPressed: () {
                                  _fetchMoviesForCategory(
                                      cat, (_categoryPages[cat] ?? 1) + 1);
                                },
                              ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}

Row buildStarRating(String rating) {
  List<Widget> stars = [];
  try {
    double ratingValue = double.parse(rating);
    int fullStars = ratingValue.floor();
    bool halfStar = (ratingValue - fullStars) >= 0.5;
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, size: 16, color: Colors.orange));
      } else if (i == fullStars && halfStar) {
        stars.add(const Icon(Icons.star_half, size: 16, color: Colors.orange));
      } else {
        stars
            .add(const Icon(Icons.star_border, size: 16, color: Colors.orange));
      }
    }
  } catch (e) {
    stars.add(const Icon(Icons.star_border, size: 16, color: Colors.orange));
  }
  return Row(children: stars);
}

class ExploreScreen extends StatefulWidget {
  final List<model.Movie> favoriteMovies;
  final void Function(model.Movie) onToggleFavorite;

  const ExploreScreen({
    super.key,
    required this.favoriteMovies,
    required this.onToggleFavorite,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? filterYear;
  String? filterCategory;

  // To trigger reload on filter
  late Map<String, Future<List<model.Movie>>> _categoryFutures;

  @override
  void initState() {
    super.initState();
    _loadCategoryFutures();
  }

  void _loadCategoryFutures() {
    final random = Random();
    _categoryFutures = {
      for (var cat in categories)
        cat: fetchMoviesWithFilters(
          title: cat == 'Trending'
              ? DateTime.now().year.toString()
              : cat, // Use year for Trending
          year: filterYear ?? '',
          category: filterCategory == null || filterCategory == 'All'
              ? cat
              : filterCategory,
          country: '',
          maxPages: 1,
          page: 1 + random.nextInt(10),
        ),
    };
  }

  void _showFilterDialog() {
    String tempYear = filterYear ?? '';
    String tempCategory = filterCategory ?? 'All';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Filter', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Year',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => tempYear = v,
                controller: TextEditingController(text: tempYear),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tempCategory,
                dropdownColor: Colors.grey[900],
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                items: ['All', ...categories].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child:
                        Text(cat, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (v) => tempCategory = v ?? 'All',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.deepPurple)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  filterYear = tempYear.isEmpty ? null : tempYear;
                  filterCategory = tempCategory == 'All' ? null : tempCategory;
                  _loadCategoryFutures();
                });
                Navigator.pop(context);
              },
              child: const Text('Apply',
                  style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Explore', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var cat in (filterCategory != null && filterCategory != 'All'
              ? [filterCategory!]
              : categories))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    cat,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      420, // enough for 3 rows of 4 posters (3 * 180 + spacing)
                  child: FutureBuilder<List<model.Movie>>(
                    future: _categoryFutures[cat],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No movies found.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }
                      final movies = snapshot.data!.take(12).toList();
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.67,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final url =
                                      'https://www.omdbapi.com/?apikey=7fc7afd1&i=${movie.imdbID}&plot=full';
                                  final response =
                                      await http.get(Uri.parse(url));
                                  if (response.statusCode == 200) {
                                    final data = json.decode(response.body);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MovieDetailsScreen(
                                          movie: movie,
                                          rating: data['imdbRating'] ?? 'N/A',
                                          genre: data['Genre'] ?? 'N/A',
                                          plot: data['Plot'] ?? 'N/A',
                                          cast: data['Actors'] ?? 'N/A',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    movie.poster!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              // Favorite icon button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: Icon(
                                    widget.favoriteMovies.any(
                                            (fav) => fav.imdbID == movie.imdbID)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    widget.onToggleFavorite(movie);
                                    setState(() {});
                                  },
                                ),
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
        ],
      ),
    );
  }
}

class FavoriteScreen extends StatelessWidget {
  final List<model.Movie> favoriteMovies;
  final void Function(model.Movie) onRemoveFavorite;

  const FavoriteScreen({
    super.key,
    required this.favoriteMovies,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet!',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.poster!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onRemoveFavorite(movie),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _editName(BuildContext context) async {
    final controller = TextEditingController(text: currentUser?.userName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && currentUser != null) {
      setState(() {
        currentUser!.name = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: Text('No user logged in',
                  style: TextStyle(color: Colors.white)),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.userName ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.userEmail ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _editName(context),
                    child: const Text('Edit Name'),
                  ),
                ],
              ),
            ),
    );
  }
}
