import 'package:dio/dio.dart';

import '../models/movie_details.dart';
import '../response/movie_details_response.dart';

class MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSource({required this.dio});

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final response = await dio.get(
      '/movie_details.json',
      queryParameters: {
        'movie_id': movieId,
        'with_images': true,
        'with_cast': true,
      },
    );

    final model = MovieDetailsResponse.fromJson(response.data);
    return model.data.movie;
  }
}