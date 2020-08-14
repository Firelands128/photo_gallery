part of photogallery;

/// Fetches the given album thumbnail from the gallery.
class AlbumThumbnailProvider extends ImageProvider<AlbumThumbnailProvider> {
  const AlbumThumbnailProvider({
    @required this.albumId,
    this.height,
    this.width,
    this.highQuality = false,
  }) : assert(albumId != null);

  final String albumId;
  final int height;
  final int width;
  final bool highQuality;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: $albumId');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      AlbumThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await PhotoGallery.getAlbumThumbnail(
      albumId: albumId,
      height: height,
      width: width,
      highQuality: highQuality,
    );
    if (bytes == null || bytes.length == 0)
      return await decode(kTransparentImage);

    return await decode(bytes);
  }

  @override
  Future<AlbumThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AlbumThumbnailProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final AlbumThumbnailProvider typedOther = other;
    return albumId == typedOther.albumId;
  }

  @override
  int get hashCode => albumId?.hashCode ?? 0;

  @override
  String toString() => '$runtimeType("$albumId")';
}
