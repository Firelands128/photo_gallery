library photogallery;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

part 'src/common/medium_type.dart';
part 'src/image_providers/album_thumbnail_provider.dart';
part 'src/image_providers/photo_provider.dart';
part 'src/image_providers/thumbnail_provider.dart';
part 'src/models/album.dart';
part 'src/models/media_page.dart';
part 'src/models/medium.dart';

/// Accessing the native photo gallery.
class PhotoGallery {
  static const MethodChannel _channel = const MethodChannel('photo_gallery');

  /// List all available photo gallery albums and counts number of
  /// items of [MediumType].
  static Future<List<Album>> listAlbums({
    @required MediumType mediumType,
  }) async {
    assert(mediumType != null);
    final json = await _channel.invokeMethod('listAlbums', {
      'mediumType': mediumTypeToJson(mediumType),
    });
    return json.map<Album>((x) => Album.fromJson(x)).toList();
  }

  static Future<MediaPage> _listMedia({
    @required Album album,
    @required MediumType mediumType,
    @required int total,
    int skip,
    int take,
  }) async {
    assert(album.id != null);
    final json = await _channel.invokeMethod('listMedia', {
      'albumId': album.id,
      'mediumType': mediumTypeToJson(mediumType),
      'total': total,
      'skip': skip,
      'take': take,
    });
    return MediaPage.fromJson(album, mediumType, json);
  }

  static Future<Medium> getMedium({
    @required String mediumId,
    MediumType mediumType,
  }) async {
    assert(mediumId != null);
    final json = await _channel.invokeMethod('getMedium', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    });
    return Medium.fromJson(json);
  }

  static Future<List<dynamic>> getThumbnail({
    @required String mediumId,
    MediumType mediumType,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(mediumId != null);
    final bytes = await _channel.invokeMethod('getThumbnail', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    return bytes;
  }

  static Future<List<dynamic>> getAlbumThumbnail({
    @required String albumId,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(albumId != null);
    final bytes = await _channel.invokeMethod('getAlbumThumbnail', {
      'albumId': albumId,
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    return bytes;
  }

  static Future<File> getFile({
    @required String mediumId,
    MediumType mediumType,
  }) async {
    assert(mediumId != null);
    final path = await _channel.invokeMethod('getFile', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    }) as String;
    return File(path);
  }
}
