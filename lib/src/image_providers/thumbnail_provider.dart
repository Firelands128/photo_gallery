part of photogallery;

/// Fetches the given medium thumbnail from the gallery.
class ThumbnailProvider extends ImageProvider<ThumbnailProvider> {
  const ThumbnailProvider({
    required this.mediumId,
    this.mediumType,
    this.height,
    this.width,
    this.highQuality,
  });

  final String mediumId;
  final MediumType? mediumType;
  final int? height;
  final int? width;
  final bool? highQuality;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: $mediumId');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      ThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await PhotoGallery.getThumbnail(
      mediumId: mediumId,
      mediumType: mediumType,
      height: height,
      width: width,
      highQuality: highQuality,
    );
    return await decode(Uint8List.fromList(bytes));
  }

  @override
  Future<ThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ThumbnailProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final ThumbnailProvider typedOther = other;
    return mediumId == typedOther.mediumId;
  }

  @override
  int get hashCode => mediumId.hashCode;

  @override
  String toString() => '$runtimeType("$mediumId")';
}
