import 'dart:io';

import 'package:photo_gallery/photo_gallery.dart';

class Generator {
  static dynamic generateAlbumsJson({
    MediumType? mediumType = MediumType.image,
    bool? newest = true,
  }) {
    return [
      {
        "id": "__ALL__",
        "mediumType": mediumTypeToJson(mediumType),
        "newest": newest,
        "name": "All",
        "count": 5,
      },
      {
        "id": "AlbumId",
        "mediumType": mediumTypeToJson(mediumType),
        "newest": newest,
        "name": "AlbumName",
        "count": 5,
      }
    ];
  }

  static List<Album> generateAlbums({
    MediumType? mediumType,
    bool newest = true,
  }) {
    return Generator.generateAlbumsJson(mediumType: mediumType, newest: newest)
        .map<Album>((x) => Album.fromJson(x, mediumType, newest))
        .toList();
  }

  static dynamic generateMediaPageJson({
    required String albumId,
    MediumType? mediumType,
    int? skip,
    int? take,
  }) {
    skip = skip ?? 0;
    take = take ?? 10;
    var items = [];
    int index = skip;
    while (index < skip + take) {
      items.add(generateMediaJson(
        mediumId: index.toString(),
        mediumType: mediumType,
      ));
      index++;
    }

    return {
      "start": skip,
      "items": items,
    };
  }

  static dynamic generateMediaJson({
    required String mediumId,
    MediumType? mediumType,
  }) {
    return {
      "id": mediumId,
      "mediumType": mediumTypeToJson(mediumType),
      "width": 512,
      "height": 512,
      "mimeType": "image/jpeg",
      "duration": 3600,
      "creationDate": DateTime(2020, 8, 1).millisecondsSinceEpoch,
      "modifiedDate": DateTime(2020, 9, 1).millisecondsSinceEpoch,
    };
  }

  static MediaPage generateMediaPage({
    required Album album,
    MediumType? mediumType,
    int? skip,
    int? take,
  }) {
    dynamic json = generateMediaPageJson(
      albumId: album.id,
      mediumType: mediumType,
      skip: skip,
      take: take ?? album.count,
    );
    return MediaPage.fromJson(album, json);
  }

  static Medium generateMedia({
    required String mediumId,
    MediumType? mediumType,
  }) {
    return Medium.fromJson(
      generateMediaJson(mediumId: mediumId, mediumType: mediumType),
    );
  }

  static List<int> generateMockThumbnail({
    required String mediumId,
    MediumType? mediumType,
  }) {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9];
  }

  static List<int> generateMockAlbumThumbnail({
    required String albumId,
  }) {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9];
  }

  static String generateFilePath({
    required String mediumId,
    MediumType? mediumType,
  }) {
    return "/path/to/file";
  }

  static File generateFile({
    required String mediumId,
    MediumType? mediumType,
  }) {
    return File(generateFilePath(mediumId: mediumId, mediumType: mediumType));
  }
}
