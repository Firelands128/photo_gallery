import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'utils/generator.dart';
import 'utils/mock_handler.dart';

void main() {
  const MethodChannel channel = MethodChannel('photo_gallery');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      mockMethodCallHandler,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      null,
    );
  });

  test('list albums', () async {
    MediumType mediumType = MediumType.image;
    bool newest = true;
    var result = await PhotoGallery.listAlbums(mediumType: mediumType);
    var expected = Generator.generateAlbums(
      mediumType: mediumType,
      newest: newest,
    );
    expect(result, expected);
  });

  test('list media', () async {
    MediumType mediumType = MediumType.image;
    int skip = 0;
    int take = 1;
    List<Album> albums = await PhotoGallery.listAlbums(mediumType: mediumType);
    Album allAlbum = albums.firstWhere((element) => element.isAllAlbum);
    MediaPage result = await allAlbum.listMedia(skip: skip, take: take);
    MediaPage expected = Generator.generateMediaPage(
      album: allAlbum,
      mediumType: mediumType,
      skip: skip,
      take: take,
    );
    expect(result, expected);
  });

  test('get medium', () async {
    String mediumId = 0.toString();
    MediumType mediumType = MediumType.image;
    Medium result = await PhotoGallery.getMedium(
      mediumId: mediumId,
      mediumType: mediumType,
    );
    Medium expected =
        Generator.generateMedia(mediumId: mediumId, mediumType: mediumType);
    expect(result, expected);
  });

  test('get thumbnail', () async {
    String mediumId = 0.toString();
    MediumType mediumType = MediumType.image;
    List result = await PhotoGallery.getThumbnail(
        mediumId: mediumId, mediumType: mediumType);
    List expected = Generator.generateMockThumbnail(
        mediumId: mediumId, mediumType: mediumType);
    expect(result, expected);
  });

  test('get album thumbnail', () async {
    String albumId = "__ALL__";
    List result = await PhotoGallery.getAlbumThumbnail(albumId: albumId);
    List expected = Generator.generateMockAlbumThumbnail(albumId: albumId);
    expect(result, expected);
  });

  test('get file', () async {
    String mediumId = 0.toString();
    MediumType mediumType = MediumType.image;
    File result =
        await PhotoGallery.getFile(mediumId: mediumId, mediumType: mediumType);
    File expected =
        Generator.generateFile(mediumId: mediumId, mediumType: mediumType);
    expect(result.path, expected.path);
  });
}
