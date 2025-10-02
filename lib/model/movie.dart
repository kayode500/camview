// Place this Movie class at the TOP of your home_page.dart file, before any usage.

class Movie {
  final String title;
  final String? poster;
  final String year;
  final String type;
  final String imdbID;

  Movie({
    required this.title,
    required this.poster,
    required this.year,
    required this.type,
    required this.imdbID,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? '',
      poster: json['Poster'],
      year: json['Year'] ?? '',
      type: json['Type'] ?? '',
      imdbID: json['imdbID'] ?? '',
    );
  }
}
