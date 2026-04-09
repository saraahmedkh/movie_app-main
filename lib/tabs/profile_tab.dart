import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/api/api_manager.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/update_profile/update_profile_screen.dart';
import 'package:movie_app/services/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/movie_detail_screen/movie_details_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String userName = "";
  String userEmail = "";
  int avatarId = 1;

  List<Movie> watchList = [];
  List<Movie> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          userName = user?.displayName ?? prefs.getString('name') ?? 'User';
          userEmail = user?.email ?? prefs.getString('email') ?? '';
          avatarId = int.tryParse(prefs.getString('avatar') ?? '1') ?? 1;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    final wl = await ApiManager.getWatchlist();
    final hist = await ApiManager.getHistory();

    if (mounted) {
      setState(() {
        watchList = wl;
        history = hist;
        isLoading = false;
      });
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
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMoviesGrid(watchList, showDelete: true),
                  _buildMoviesGrid(history, showDelete: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAvatarColor(avatarId).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFFFFB800), width: 2),
                ),
                child: ClipOval(
                  child: Center(child: _buildAvatarImage(avatarId)),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(watchList.length.toString(), 'Wish List'),
                    _buildStatItem(history.length.toString(), 'History'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateProfileScreen(),
                        ),
                      );
                      if (result == true) _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showExitDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Exit',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.logout, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFFFFB800),
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      tabs: const [
        Tab(icon: Icon(Icons.list, size: 22), text: 'Watch List'),
        Tab(icon: Icon(Icons.folder, size: 22), text: 'History'),
      ],
    );
  }

  Widget _buildMoviesGrid(List<Movie> movies, {required bool showDelete}) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/popcornicon.png",
              width: 130,
              height: 130,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.movie_filter_outlined,
                size: 100,
                color: Color(0xFFFFB800),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return _buildMovieCard(movies[index], showDelete: showDelete);
      },
    );
  }

  Widget _buildMovieCard(Movie movie, {required bool showDelete}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: movie.id),
        ),
      ),
      onLongPress: showDelete ? () => _showRemoveDialog(movie) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              movie.mediumCoverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[850],
                child: const Icon(Icons.movie, size: 40, color: Colors.white30),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.star, color: Color(0xFFFFB800), size: 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(int id) {
    return Image.asset(
      'assets/images/ava$id.png',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.person,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  Color _getAvatarColor(int id) {
    final colors = [
      const Color(0xFF5DADE2),
      const Color(0xFF48C9B0),
      const Color(0xFFF39C12),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
    ];
    return colors[(id - 1) % colors.length];
  }

  void _showRemoveDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove from Watchlist',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${movie.title}" from your watchlist?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiManager.removeFromWatchlist(movie.id);
              if (mounted) Navigator.pop(context);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}