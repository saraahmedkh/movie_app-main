import 'package:flutter/material.dart';
import 'package:movie_app/api/api_manager.dart';
import 'package:movie_app/models/movie_details.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiManager apiService = ApiManager();
  late Future<MovieDetails?> movieFuture;
  bool _inWatchlist = false;
  List<MovieDetails> similarMovies = [];

  @override
  void initState() {
    super.initState();
    movieFuture = apiService.getMovieDetails(widget.movieId);
    _checkWatchlist();
    _saveToHistory();
    _loadSimilarMovies();
  }

  Future<void> _saveToHistory() async {
    final movie = await movieFuture;
    if (movie != null) {
      await ApiManager.addToHistory(movie.toMovie());
    }
  }

  Future<void> _checkWatchlist() async {
    final result = await ApiManager.isInWatchlist(widget.movieId);
    if (mounted) setState(() => _inWatchlist = result);
  }

  Future<void> _loadSimilarMovies() async {
    try {
      final results = await apiService.getMovies(limit: 6, sortBy: 'rating');
      if (mounted) {
        setState(() {
          similarMovies = results
              .where((m) => m.id != widget.movieId)
              .take(4)
              .map((m) => MovieDetails(
                    id: m.id,
                    title: m.title,
                    year: m.year,
                    rating: m.rating,
                    runtime: m.runtime,
                    likeCount: m.likeCount,
                    largeCoverImage: m.largeCoverImage,
                    backgroundImageOriginal: m.backgroundImage,
                    genres: m.genres,
                    cast: [],
                  ))
              .toList();
        });
      }
    } catch (e) {
      print('Similar movies error: $e');
    }
  }

  Future<void> _toggleWatchlist(MovieDetails movie) async {
    if (_inWatchlist) {
      await ApiManager.removeFromWatchlist(movie.id);
    } else {
      await ApiManager.addToWatchlist(movie.toMovie());
      await apiService.addToFavorites(
        movieID: movie.id.toString(),
        name: movie.title,
        rating: movie.rating,
        imageUrl: movie.largeCoverImage,
        year: movie.year.toString(),
      );
    }
    if (mounted) setState(() => _inWatchlist = !_inWatchlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<MovieDetails?>(
        future: movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)),
            );
          }
          final movie = snapshot.data;
          if (movie == null) {
            return const Center(
              child: Text("No Data", style: TextStyle(color: Colors.white)),
            );
          }

          final screenshots = [
            movie.mediumScreenshotImage1,
            movie.mediumScreenshotImage2,
            movie.mediumScreenshotImage3,
          ].where((e) => e != null && e.isNotEmpty).cast<String>().toList();

          return Stack(
            children: [
              // BACKGROUND POSTER
              Positioned.fill(
                child: Image.network(
                  movie.largeCoverImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.85),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP ICONS
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _circleIcon(
                              icon: Icons.arrow_back_ios_new,
                              onTap: () => Navigator.pop(context),
                            ),
                            _circleIcon(
                              icon: _inWatchlist
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              onTap: () => _toggleWatchlist(movie),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 90),

                      Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.amber, width: 6),
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber,
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  size: 48, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 220),

                      // TITLE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // YEAR
                      Center(
                        child: Text(
                          movie.year.toString(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Watch",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                                child: _infoCard(
                                    icon: Icons.favorite,
                                    value: movie.likeCount.toString())),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _infoCard(
                                    icon: Icons.access_time_rounded,
                                    value: movie.runtime.toString())),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _infoCard(
                                    icon: Icons.star_rounded,
                                    value: movie.rating.toStringAsFixed(1))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (movie.genres.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Genres",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: movie.genres.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFFFB800), width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                movie.genres[i],
                                style: const TextStyle(
                                    color: Color(0xFFFFB800),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (screenshots.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Screen Shots",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: screenshots.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (_, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                screenshots[index],
                                width: 280,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 280, color: Colors.grey[800]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if ((movie.descriptionFull ?? '').isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Overview",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            movie.descriptionFull!,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                                height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (movie.cast.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Cast",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: movie.cast.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final actor = movie.cast[i];
                            return Row(
                              children: [
                                // Actor photo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: actor.urlSmallImage != null
                                      ? Image.network(
                                          actor.urlSmallImage!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _avatarPlaceholder(),
                                        )
                                      : _avatarPlaceholder(),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      actor.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (actor.characterName != null)
                                      Text(
                                        "Character: ${actor.characterName}",
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontSize: 13),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (similarMovies.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Similar",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: similarMovies.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final m = similarMovies[i];
                              return GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MovieDetailsScreen(movieId: m.id),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    m.largeCoverImage,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.movie,
                                          color: Colors.white38),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey[800],
      child: const Icon(Icons.person, color: Colors.white38, size: 30),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String value}) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
