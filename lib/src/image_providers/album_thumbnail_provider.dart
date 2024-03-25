part of '../../photo_gallery.dart';

/// Fetches the given album thumbnail from the gallery.
class AlbumThumbnailProvider extends ImageProvider<AlbumThumbnailProvider> {
  /// ImageProvider of album thumbnail
  const AlbumThumbnailProvider({
    required this.album,
    this.height,
    this.width,
    this.highQuality = false,
  });

  /// Album info
  final Album album;

  /// Height of album thumbnail
  final int? height;

  /// Width of album thumbnail
  final int? width;

  /// Whether using high quality of album thumbnail
  final bool? highQuality;

  @override
  ImageStreamCompleter loadImage(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${album.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
    AlbumThumbnailProvider key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);
    late ui.ImmutableBuffer buffer;
    try {
      final data = await PhotoGallery.getAlbumThumbnail(
        albumId: album.id,
        mediumType: album.mediumType,
        newest: album.newest,
        height: height,
        width: width,
        highQuality: highQuality,
      );
      buffer = await ui.ImmutableBuffer.fromUint8List(Uint8List.fromList(data));
    } catch (e) {
      buffer = await ui.ImmutableBuffer.fromAsset(
        "packages/photo_gallery/images/grey.bmp",
      );
    }
    return decode(buffer);
  }

  @override
  Future<AlbumThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AlbumThumbnailProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final typedOther = other as AlbumThumbnailProvider;
    return album.id == typedOther.album.id;
  }

  @override
  int get hashCode => album.id.hashCode;

  @override
  String toString() => '$runtimeType("${album.id}")';
}
