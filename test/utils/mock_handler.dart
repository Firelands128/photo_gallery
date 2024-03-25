import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'generator.dart';

Future<dynamic> mockMethodCallHandler(MethodCall call) async {
  if (call.method == "listAlbums") {
    MediumType? mediumType = jsonToMediumType(call.arguments['mediumType']);
    bool newest = call.arguments['newest'];
    dynamic albums = Generator.generateAlbumsJson(
      mediumType: mediumType,
      newest: newest,
    );
    return albums;
  } else if (call.method == "listMedia") {
    String albumId = call.arguments['albumId'];
    MediumType? mediumType = jsonToMediumType(call.arguments['mediumType']);
    int? skip = call.arguments['skip'];
    int? take = call.arguments['take'];
    dynamic mediaPage = Generator.generateMediaPageJson(
      albumId: albumId,
      mediumType: mediumType,
      skip: skip,
      take: take,
    );
    return mediaPage;
  } else if (call.method == "getMedium") {
    String mediumId = call.arguments['mediumId'];
    MediumType? mediumType = jsonToMediumType(call.arguments['mediumType']);
    dynamic media =
        Generator.generateMediaJson(mediumId: mediumId, mediumType: mediumType);
    return media;
  } else if (call.method == "getThumbnail") {
    String mediumId = call.arguments['mediumId'];
    MediumType? mediumType = jsonToMediumType(call.arguments['mediumType']);
    dynamic thumbnail = Generator.generateMockThumbnail(
        mediumId: mediumId, mediumType: mediumType);
    return thumbnail;
  } else if (call.method == "getAlbumThumbnail") {
    String albumId = call.arguments['albumId'];
    dynamic thumbnail = Generator.generateMockAlbumThumbnail(albumId: albumId);
    return thumbnail;
  } else if (call.method == "getFile") {
    String mediumId = call.arguments['mediumId'];
    MediumType? mediumType = jsonToMediumType(call.arguments['mediumType']);
    dynamic path =
        Generator.generateFilePath(mediumId: mediumId, mediumType: mediumType);
    return path;
  }
  throw UnimplementedError();
}
