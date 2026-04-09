import 'package:flutter/material.dart';
import 'package:movie_app/api/api_manager.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/movie_detail_screen/movie_details_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiManager apiManager = ApiManager();

  List<Movie> availableNowMovies = [];
  List<Movie> watchNowMovies = [];
  List<Movie> actionMovies = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => isLoading = true);
    try {
      final topRatedResponse = await apiManager.getMovies(
        limit: 20,
        sortBy: 'rating',
      );

      final latestResponse = await apiManager.getMovies(
        limit: 20,
        sortBy: 'date_added',
      );

      final actionResponse = await apiManager.getMovies(
        limit: 20,
        genre: 'action',
        sortBy: 'rating',
      );

      if (mounted) {
        setState(() {
          availableNowMovies = topRatedResponse;
          watchNowMovies     = latestResponse;
          actionMovies       = actionResponse;
          isLoading          = false;
        });
      }
    } catch (e) {
      print('Error loading movies: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB800)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _loadMovies,
        color: const Color(0xFFFFB800),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildAvailableNowSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(child: _buildWatchNowSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(child: _buildActionSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableNowSection() {
    if (availableNowMovies.isEmpty) return const SizedBox();
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Text(
            'Available Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pacifico',
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 520,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.75),
            itemCount: availableNowMovies.length,
            itemBuilder: (context, index) {
              return _buildFeaturedCard(availableNowMovies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: movie.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                movie.largeCoverImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.movie, size: 100, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.year.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, color: Color(0xFFFFB800), size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchNowSection() {
    if (watchNowMovies.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20), child: Text(
            'Watch Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pacifico',
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: watchNowMovies.length,
            itemBuilder: (context, index) {
              return _buildMovieCard(watchNowMovies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    if (actionMovies.isEmpty) return const SizedBox();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Action',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'See More',
                      style: TextStyle(
                        color: Color(0xFFFFB800),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Color(0xFFFFB800), size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: actionMovies.length,
            itemBuilder: (context, index) {
              return _buildMovieCard(actionMovies[index]);
            },
          ),
        ),
      ],
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
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                movie.mediumCoverImage,
                width: 150,
                height: 230,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 150,
                  height: 230,
                  color: Colors.grey[800],
                  child: const Icon(Icons.movie, size: 50, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
