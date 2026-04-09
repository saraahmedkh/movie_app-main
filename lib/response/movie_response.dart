import '../models/movie.dart';

class MovieResponse {
  String? status;
  String? statusMessage;
  List<Movie> movies;

  MovieResponse({this.status, this.statusMessage, required this.movies});

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final moviesJson = data['movies'] as List<dynamic>? ?? [];

    final movies = moviesJson.map((m) => Movie(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      year: m['year'] ?? 0,
      rating: (m['rating'] ?? 0).toDouble(),
      runtime: m['runtime'] ?? 0,
      likeCount: m['like_count'] ?? 0,
      genres: List<String>.from(m['genres'] ?? []),
      largeCoverImage: m['large_cover_image'] ?? '',
      mediumCoverImage: m['medium_cover_image'] ?? '',
      backgroundImage: m['background_image_original'] ?? m['background_image'] ?? '',
      descriptionFull: m['description_full'] ?? '',
      screenshotImage1: m['medium_screenshot_image1'] ?? '',
      screenshotImage2: m['medium_screenshot_image2'] ?? '',
      screenshotImage3: m['medium_screenshot_image3'] ?? '',
    )).toList();

    return MovieResponse(
      status: json['status'],
      statusMessage: json['status_message'],
      movies: movies,
    );
  }
}