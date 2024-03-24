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
  static const MethodChannel _channel = MethodChannel('photo_gallery');

  /// List all available gallery albums and counts number of items of [MediumType].
  /// mediumType: medium type of albums
  /// newest: whether to sort media by latest date in albums
  /// hideIfEmpty: whether to hide empty albums, only available on iOS
  static Future<List<Album>> listAlbums({
    MediumType? mediumType,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {
    final json = await _channel.invokeMethod('listAlbums', {
      'mediumType': mediumTypeToJson(mediumType),
      'hideIfEmpty': hideIfEmpty,
    });
    return json.map<Album>((album) => Album.fromJson(album, mediumType, newest)).toList();
  }

  /// List all available media in a specific album, support pagination of media
  /// album: the album to list media
  /// skip: the number to skip when list media
  /// take: the number to return when list media
  /// lightWeight: whether to return brief information when list media
  static Future<MediaPage> _listMedia({
    required Album album,
    int? skip,
    int? take,
    bool? lightWeight,
  }) async {
    final json = await _channel.invokeMethod('listMedia', {
      'albumId': album.id,
      'mediumType': mediumTypeToJson(album.mediumType),
      'newest': album.newest,
      'skip': skip,
      'take': take,
      'lightWeight': lightWeight,
    });
    return MediaPage.fromJson(album, json);
  }

  /// Get medium metadata by medium id
  /// mediumId: the identifier of medium
  /// mediumType: the type of medium
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
  /// mediumId: the identifier of medium
  /// width: the width of medium
  /// height: the height of medium
  /// heightQuality: whether to use high quality of medium thumbnail
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
    return List<int>.from(bytes);
  }

  /// Get album thumbnail by album id
  /// mediumType: the type of medium
  /// newest: whether to get the newest medium or oldest medium as album thumbnail
  /// width: the width of thumbnail
  /// height: the height of thumbnail
  /// highQuality: whether to use high quality of album thumbnail
  static Future<List<int>> getAlbumThumbnail({
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
    if (bytes == null) throw "Failed to fetch thumbnail of album $albumId";
    return List<int>.from(bytes);
  }

  /// get medium file by medium id
  /// mediumType: the type of medium
  /// mimeType: the mime type of medium
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

  /// Delete medium by medium id
  /// mediumId: the identifier of medium
  /// mediumType: the type of medium
  static Future<void> deleteMedium({
    required String mediumId,
    MediumType? mediumType,
  }) async {
    await _channel.invokeMethod('deleteMedium', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    });
  }

  /// Clean medium file cache
  static Future<void> cleanCache() async {
    _channel.invokeMethod('cleanCache', {});
  }
}
