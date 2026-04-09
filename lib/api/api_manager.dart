import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/movie_details.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiManager {
  static late final Dio dio;
  static const _watchlistKey = 'watchlist';
  static const _historyKey = 'history';

  String? _authToken;

  // Singleton pattern
  static final ApiManager _instance = ApiManager._internal();

  factory ApiManager() => _instance;

  ApiManager._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://movies-api.accel.li/api/v2/",
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    dio.interceptors.add(
      PrettyDioLogger(
        request: true,
        requestHeader: true,
        responseBody: true,
        requestBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) {
        handleDioError(error);
        handler.next(error);
      },
    ));
  }

  void setToken(String token) => _authToken = token;
  void removeToken() => _authToken = null;
  String? getToken() => _authToken;

  static final Dio _ytsDio = Dio(
    BaseOptions(
      baseUrl: 'https://movies-api.accel.li/api/v2/',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<List<Movie>> getMovies({
    int page = 1,
    int limit = 20,
    String quality = "all",
    String genre = "all",
    String sortBy = 'date_add',
  }) async {
    try {
      print("STEP 1: API CALL STARTED");
      final response = await _ytsDio.get('/list_movies.json', queryParameters: {
        "page": page,
        "limit": limit,
        "quality": quality,
        "genre": genre,
        "sort_by": sortBy,
      });
      print("STEP 2: STATUS CODE = ${response.statusCode}");
      print("STEP 3: RAW DATA = ${response.data}");
      if (response.data['status'] == 'ok') {
        final movies = response.data['data']['movies'];
        if (movies == null) return [];
        return (movies as List).map((m) => Movie.fromJson(m)).toList();
      }
      return [];
    } on DioException catch (e) {
      handleDioError(e);
      print("STEP 4: API ERROR = $e");
      return [];
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _ytsDio.get('/list_movies.json', queryParameters: {
        "query_term": query,
        "limit": 20,
      });
      if (response.data["status"] == "ok") {
        final movies = response.data["data"]["movies"];
        if (movies == null) return [];
        return (movies as List).map((m) => Movie.fromJson(m)).toList();
      }
      return [];
    } on DioException catch (e) {
      handleDioError(e);
      return [];
    }
  }

  Future<MovieDetails?> getMovieDetails(int movieId) async {
    try {
      final response = await _ytsDio.get(
        '/movie_details.json',
        queryParameters: {
          "movie_id": movieId,
          "with_images": true,
          "with_cast": true,
        },
      );
      if (response.data["status"] == "ok") {
        return MovieDetails.fromJson(response.data["data"]["movie"]);
      }
      return null;
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    }
  }

  static Future login(String email, String password) async {
    try {
      final response = await dio.post(
        "auth/login",
        data: {"email": email, "password": password},
      );
      return response.data;
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    }
  }

  static Future register(
    String name,
    String email,
    String password,
    String confirmPassword,
    String phone,
    String avatarId,
  ) async {
    try {
      final response = await dio.post(
        "auth/register",
        data: {
          "name": name,
          "email": email,
          "password": password,
          "confirmPassword": confirmPassword,
          "phone": phone,
          "avatarId": avatarId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    }
  }

  Future resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.patch(
        "auth/reset-password",
        data: {"oldPassword": oldPassword, "newPassword": newPassword},
      );
      return response.data;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('profile');
      return response.data;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  Future updateProfile(
      String? name, String? phone, String? email, int? avatarId) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (avatarId != null) data['avatarId'] = avatarId;
      final response = await dio.patch('profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  static Future deleteProfile() async {
    try {
      final response = await dio.delete('profile');
      return response.data;
    } on DioException catch (e) {
      handleDioError(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> getAllFavorites() async {
    try {
      final response = await dio.get("favorites/all");
      return response.data;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  Future<Map<String, dynamic>> addToFavorites({
    required String movieID,
    required String name,
    required double rating,
    required String imageUrl,
    required String year,
  }) async {
    try {
      final response = await dio.post("favorites/add", data: {
        'movieID': movieID,
        'name': name,
        'rating': rating,
        'imageUrl': imageUrl,
        'year': year,
      });
      return response.data;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  Future<Map<String, dynamic>> removeFromFavorites(String movieId) async {
    try {
      final response = await dio.delete('favorites/remove/$movieId');
      return response.data;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  Future<bool> isFavorite(String movieId) async {
    try {
      final response = await dio.get('favorites/is-favorite/$movieId');
      return response.data['data'] ?? false;
    } on DioException catch (e) {
      throw extractErrorMessage(e);
    }
  }

  static Future<List<Movie>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_watchlistKey) ?? [];
    return raw.map((s) => Movie.fromJson(json.decode(s))).toList();
  }

  static Future<void> addToWatchlist(Movie movie) async {
    final list = await getWatchlist();
    if (list.any((m) => m.id == movie.id)) return;
    list.insert(0, movie);
    await _saveWatchlist(list);
  }

  static Future<void> removeFromWatchlist(int movieId) async {
    final list = await getWatchlist();
    list.removeWhere((m) => m.id == movieId);
    await _saveWatchlist(list);
  }

  static Future<bool> isInWatchlist(int movieId) async {
    final list = await getWatchlist();
    return list.any((m) => m.id == movieId);
  }

  static Future<void> _saveWatchlist(List<Movie> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _watchlistKey,
      list.map((m) => json.encode(m.toJson())).toList(),
    );
  }

  static Future<List<Movie>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.map((s) => Movie.fromJson(json.decode(s))).toList();
  }

  static Future<void> addToHistory(Movie movie) async {
    final list = await getHistory();
    list.removeWhere((m) => m.id == movie.id);
    list.insert(0, movie);
    if (list.length > 50) list.removeLast();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      list.map((m) => json.encode(m.toJson())).toList(),
    );
  }

  static void handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print("Connection Timeout: Check your internet connection.");
        break;
      case DioExceptionType.receiveTimeout:
        print("Server Timeout: The server is taking too long to respond.");
        break;
      case DioExceptionType.badResponse:
        print("Server Error: ${e.response?.statusCode} - ${e.response?.data}");
        break;
      case DioExceptionType.connectionError:
        print("No Internet connection.");
        break;
      default:
        print("Network Error: ${e.message}");
    }
  }

  String extractErrorMessage(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
