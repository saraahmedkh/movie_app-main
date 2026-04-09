import 'movie.dart';

class MovieDetails {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final int likeCount;
  final String largeCoverImage;
  final String backgroundImageOriginal;
  final String? mediumScreenshotImage1;
  final String? mediumScreenshotImage2;
  final String? mediumScreenshotImage3;
  final String? descriptionFull;
  final List<String> genres;
  final String? ytTrailerCode;
  final String? language;
  final String? mpaRating;
  final List<CastModel> cast;

  MovieDetails({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.likeCount,
    required this.largeCoverImage,
    required this.backgroundImageOriginal,
    this.mediumScreenshotImage1,
    this.mediumScreenshotImage2,
    this.mediumScreenshotImage3,
    this.descriptionFull,
    required this.genres,
    this.ytTrailerCode,
    this.language,
    this.mpaRating,
    required this.cast,
  });


  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      runtime: json['runtime'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      largeCoverImage: json['large_cover_image'] ?? '',
      backgroundImageOriginal: json['background_image_original'] ?? '',
      mediumScreenshotImage1: json['medium_screenshot_image1'],
      mediumScreenshotImage2: json['medium_screenshot_image2'],
      mediumScreenshotImage3: json['medium_screenshot_image3'],
      descriptionFull: json['description_full'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : [],
      ytTrailerCode: json['yt_trailer_code'],
      language: json['language'],
      mpaRating: json['mpa_rating'],
      cast: json['cast'] != null
          ? List<CastModel>.from(
        json['cast'].map((x) => CastModel.fromJson(x)),
      )
          : [],
    );
  }

  List<String> get screenshots {
    return [
      if ((mediumScreenshotImage1 ?? '').isNotEmpty) mediumScreenshotImage1!,
      if ((mediumScreenshotImage2 ?? '').isNotEmpty) mediumScreenshotImage2!,
      if ((mediumScreenshotImage3 ?? '').isNotEmpty) mediumScreenshotImage3!,
    ];
  }
  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      year: year,
      rating: rating,
      runtime: runtime,
      likeCount: likeCount,
      genres: genres,
      largeCoverImage: largeCoverImage,
      mediumCoverImage: largeCoverImage,
      backgroundImage: backgroundImageOriginal,
      descriptionFull: descriptionFull ?? '',
      screenshotImage1: mediumScreenshotImage1 ?? '',
      screenshotImage2: mediumScreenshotImage2 ?? '',
      screenshotImage3: mediumScreenshotImage3 ?? '',
    );
  }
}


class CastModel {
  final String name;
  final String? characterName;
  final String? urlSmallImage;
  final String? imdbCode;

  CastModel({
    required this.name,
    this.characterName,
    this.urlSmallImage,
    this.imdbCode,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] ?? '',
      characterName: json['character_name'],
      urlSmallImage: json['url_small_image'],
      imdbCode: json['imdb_code'],
    );
  }
}
