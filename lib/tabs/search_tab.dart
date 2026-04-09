import 'package:flutter/material.dart';
import 'package:movie_app/api/api_manager.dart';
import 'package:movie_app/models/movie.dart';


import '../screens/movie_detail_screen/movie_details_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final ApiManager apiManager = ApiManager();
  final TextEditingController searchController = TextEditingController();

  List<Movie> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
      hasSearched = true;
    });
    try {
      final results = await apiManager.searchMovies(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print("Search Error: $e");
      setState(() {
        isLoading = false;
        searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {});
                if (value.length > 2) {
                  performSearch(value);
                } else if (value.isEmpty) {
                  setState(() {
                    searchResults = [];
                    hasSearched = false;
                  });
                }
              },
              onSubmitted: performSearch,
            ),
          ),
          if (searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                searchController.clear();
                setState(() {
                  searchResults = [];
                  hasSearched = false;
                });
              },
              child: const Icon(Icons.clear, color: Colors.white54, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFB800)),
      );
    }
    if (searchResults.isEmpty) {
      return _buildEmptyState();
    }
    return _buildSearchResults();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/popcornicon.png",
            width: 150,
            height: 150,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.movie_filter_outlined,
              size: 120,
              color: Color(0xFFFFB800),
            ),
          ),
          const SizedBox(height: 24),
          if (hasSearched) ...[
            Text(
              'No Movies Found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchResults[index];
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
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
      },
    );
  }
}