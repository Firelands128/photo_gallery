library photogallery;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  /// List all available gallery albums and counts number of items of [MediumType].
  static Future<List<Album>> listAlbums({
    MediumType? mediumType,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {
    final json = await _channel.invokeMethod('listAlbums', {
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'hideIfEmpty': hideIfEmpty,
    });
    return json
        .map<Album>((album) => Album.fromJson(album, mediumType, newest))
        .toList();
  }

  /// List all available media in a specific album, support pagination of media
  static Future<MediaPage> _listMedia({
    required Album album,
    int? skip,
    int? take,
  }) async {
    final json = await _channel.invokeMethod('listMedia', {
      'albumId': album.id,
      'mediumType': mediumTypeToJson(album.mediumType),
      'newest': album.newest,
      'skip': skip,
      'take': take,
    });
    return MediaPage.fromJson(album, json);
  }

  /// Get medium metadata by medium id
  static Future<Medium> getMedium({
    required String mediumId,
    MediumType? mediumType,
  }) async {
    final json = await _channel.invokeMethod('getMedium', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    });
    return Medium.fromJson(json);
  }

  /// Get medium thumbnail by medium id
  static Future<List<int>> getThumbnail({
    required String mediumId,
    MediumType? mediumType,
    int? width,
    int? height,
    bool? highQuality = false,
  }) async {
    final bytes = await _channel.invokeMethod('getThumbnail', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    if (bytes == null) throw "Failed to fetch thumbnail of medium $mediumId";
    return new List<int>.from(bytes);
  }

  /// Get album thumbnail by album id
  static Future<List<int>?> getAlbumThumbnail({
    required String albumId,
    MediumType? mediumType,
    bool newest = true,
    int? width,
    int? height,
    bool? highQuality = false,
  }) async {
    final bytes = await _channel.invokeMethod('getAlbumThumbnail', {
      'albumId': albumId,
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    return bytes != null ? new List<int>.from(bytes) : null;
  }

  /// get medium file by medium id
  static Future<File> getFile({
    required String mediumId,
    MediumType? mediumType,
    String? mimeType,
  }) async {
    final path = await _channel.invokeMethod('getFile', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'mimeType': mimeType,
    }) as String?;
    if (path == null) throw "Cannot get file $mediumId with type $mimeType";
    return File(path);
  }

  static Future<void> cleanCache() async {
    _channel.invokeMethod('cleanCache', {});
  }
}
