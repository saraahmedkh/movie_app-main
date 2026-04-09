import 'package:flutter/material.dart';
import 'package:movie_app/api/api_manager.dart';
import 'package:movie_app/models/movie.dart';
import '../screens/movie_detail_screen/movie_details_screen.dart';

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  final ApiManager apiManager = ApiManager();

  bool isLoadingGenres = true;
  bool isLoadingMovies = false;

  List<Movie> movies = [];

  Set<String> genresSet = {};
  List<String> genres = [];
  String selectedGenre = '';

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    setState(() => isLoadingGenres = true);
    try {
      final result = await apiManager.getMovies(limit: 50, sortBy: 'download_count');
      final Set<String> set = {};
      for (final movie in result) {
        set.addAll(movie.genres);
      }
      setState(() {
        genresSet = set;
        genres = set.toList()..sort();
        selectedGenre = genres.isNotEmpty ? genres.first : '';
        isLoadingGenres = false;
      });
      if (selectedGenre.isNotEmpty) {
        _loadMoviesByGenre(selectedGenre);
      }
    } catch (e) {
      print('Error loading genres: $e');
      setState(() => isLoadingGenres = false);
    }
  }

  Future<void> _loadMoviesByGenre(String genre) async {
    setState(() {
      isLoadingMovies = true;
      selectedGenre = genre;
    });
    try {
      final result = await apiManager.getMovies(
        limit: 50,
        genre: genre,
        sortBy: 'rating',
      );
      setState(() {
        movies = result;
        isLoadingMovies = false;
      });
    } catch (e) {
      print('Error loading movies: $e');
      setState(() => isLoadingMovies = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            isLoadingGenres
                ? const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB800),
                ),
              ),
            )
                : _buildGenreChips(),

            Expanded(
              child: isLoadingMovies
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB800),
                ),
              )
                  : _buildMoviesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;
          return GestureDetector(
            onTap: () => _loadMoviesByGenre(genre),
            child: Container(
              margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFB800)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFFFB800),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFFFFB800),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoviesGrid() {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter_outlined,
              size: 100,
              color: Color(0xFFFFB800),
            ),
            const SizedBox(height: 16),
            Text(
              'No $selectedGenre movies found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return _buildMovieCard(movies[index]);
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: movie.id),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              movie.mediumCoverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[850],
                child: const Icon(
                  Icons.movie,
                  size: 50,
                  color: Colors.white30,
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFB800),
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}