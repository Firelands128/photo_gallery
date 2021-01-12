import 'dart:io';

import 'package:photo_gallery/photo_gallery.dart';

class Generator {
  static dynamic generateAlbumsJson({MediumType mediumType}) {
    mediumType = mediumType ?? MediumType.image;
    return [
      {
        "id": "__ALL__",
        "mediumType": mediumTypeToJson(mediumType),
        "name": "All",
        "count": 5,
      },
      {
        "id": "AlbumId",
        "mediumType": mediumTypeToJson(mediumType),
        "name": "AlbumName",
        "count": 5,
      }
    ];
  }

  static List<Album> generateAlbums({MediumType mediumType}) {
    return Generator.generateAlbumsJson(mediumType: mediumType)
        .map<Album>((x) => Album.fromJson(x))
        .toList();
  }

  static dynamic generateMediaPageJson({
    String albumId,
    MediumType mediumType,
    int total,
    int skip,
    int take,
  }) {
    skip = skip ?? 0;
    take = take ?? (total - skip);

    var items = [];
    int index = skip;
    while (index < skip + take) {
      items.add(generateMediaJson(
          mediumId: index.toString(), mediumType: mediumType));
      index++;
    }

    return {
      "start": skip,
      "total": total,
      "items": items,
    };
  }

  static dynamic generateMediaJson({
    String mediumId,
    MediumType mediumType,
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
    Album album,
    MediumType mediumType,
    int skip,
    int take,
  }) {
    dynamic json = generateMediaPageJson(
      albumId: album.id,
      mediumType: mediumType,
      total: album.count,
      skip: skip,
      take: take,
    );
    return MediaPage.fromJson(album, json);
  }

  static Medium generateMedia({
    String mediumId,
    MediumType mediumType,
  }) {
    return Medium.fromJson(
      generateMediaJson(mediumId: mediumId, mediumType: mediumType),
    );
  }

  static List<int> generateMockThumbnail({
    String mediumId,
    MediumType mediumType,
  }) {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9];
  }

  static List<int> generateMockAlbumThumbnail({
    String albumId,
  }) {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9];
  }

  static String generateFilePath({
    String mediumId,
    MediumType mediumType,
  }) {
    return "/path/to/file";
  }

  static File generateFile({
    String mediumId,
    MediumType mediumType,
  }) {
    return File(generateFilePath(mediumId: mediumId, mediumType: mediumType));
  }
}
