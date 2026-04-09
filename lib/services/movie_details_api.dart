import 'package:dio/dio.dart';

import '../models/movie_details.dart';

class MovieDetailsApi {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://movies-api.accel.li/api/v2",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final response = await dio.get(
      "/movie_details.json",
      queryParameters: {
        "movie_id": movieId,
        "with_images": true,
        "with_cast": true,
      },
    );

    final movie = response.data["data"]["movie"];
    return MovieDetails.fromJson(movie);
  }
}