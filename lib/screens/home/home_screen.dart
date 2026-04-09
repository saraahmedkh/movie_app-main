import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/api/api_manager.dart'; // تأكد من مسار الملف الصحيح

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: FutureBuilder<List<Movie>>(
        future: ApiManager().getMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB800)));
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white)));
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return const Center(
                child: Text("No movies found or Server blocked",
                    style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: movie.mediumCoverImage.isNotEmpty
                    ? Image.network(
                        movie.mediumCoverImage,
                        width: 50,
                      )
                    : const Icon(Icons.movie),
                title: Text(movie.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${movie.year} | Rating: ${movie.rating}",
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
              );
            },
          );
        },
      ),
    );
  }
}
