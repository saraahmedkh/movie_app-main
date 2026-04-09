import 'package:movie_app/models/movie_details.dart';

class MovieDetailsResponse {
  final String status;
  final String statusMessage;
  final MovieDetailsData data;

  MovieDetailsResponse({
    required this.status,
    required this.statusMessage,
    required this.data,
  });

  factory MovieDetailsResponse.fromJson(Map<String, dynamic> json) {
    return MovieDetailsResponse(
      status: json['status'] ?? '',
      statusMessage: json['status_message'] ?? '',
      data: MovieDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

class MovieDetailsData {
  final MovieDetails movie;

  MovieDetailsData({required this.movie});

  factory MovieDetailsData.fromJson(Map<String, dynamic> json) {
    return MovieDetailsData(
      movie: MovieDetails.fromJson(json['movie'] ?? {}),
    );
  }
}
