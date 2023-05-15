part of photogallery;

/// Fetches the given medium thumbnail from the gallery.
class ThumbnailProvider extends ImageProvider<ThumbnailProvider> {
  const ThumbnailProvider({
    required this.mediumId,
    this.mediumType,
    this.height,
    this.width,
    this.highQuality = false,
  });

  final String mediumId;
  final MediumType? mediumType;
  final int? height;
  final int? width;
  final bool? highQuality;

  @override
  ImageStreamCompleter loadImage(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: $mediumId');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProvider key, ImageDecoderCallback decode) async {
    assert(key == this);
    final data = await PhotoGallery.getThumbnail(
      mediumId: mediumId,
      mediumType: mediumType,
      height: height,
      width: width,
      highQuality: highQuality,
    );
    ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(Uint8List.fromList(data));
    return decode(buffer);
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
