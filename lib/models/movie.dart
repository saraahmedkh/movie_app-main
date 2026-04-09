class Movie {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final int likeCount;
  final List<String> genres;
  final String largeCoverImage;
  final String mediumCoverImage;
  final String backgroundImage;
  final String descriptionFull;
  final String screenshotImage1;
  final String screenshotImage2;
  final String screenshotImage3;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.likeCount,
    required this.genres,
    required this.largeCoverImage,
    required this.mediumCoverImage,
    required this.backgroundImage,
    required this.descriptionFull,
    required this.screenshotImage1,
    required this.screenshotImage2,
    required this.screenshotImage3,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      runtime: json['runtime'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      genres: List<String>.from(json['genres'] ?? []),
      largeCoverImage: json['large_cover_image'] ?? '',
      mediumCoverImage: json['medium_cover_image'] ?? '',
      backgroundImage: json['background_image_original'] ?? json['background_image'] ?? '',
      descriptionFull: json['description_full'] ?? '',
      screenshotImage1: json['medium_screenshot_image1'] ?? '',
      screenshotImage2: json['medium_screenshot_image2'] ?? '',
      screenshotImage3: json['medium_screenshot_image3'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'year': year,
    'rating': rating,
    'runtime': runtime,
    'like_count': likeCount,
    'genres': genres,
    'large_cover_image': largeCoverImage,
    'medium_cover_image': mediumCoverImage,
    'background_image_original': backgroundImage,
    'description_full': descriptionFull,
    'medium_screenshot_image1': screenshotImage1,
    'medium_screenshot_image2': screenshotImage2,
    'medium_screenshot_image3': screenshotImage3,
  };
}