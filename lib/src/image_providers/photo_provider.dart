part of photogallery;

/// Fetches the given image from the gallery.
class PhotoProvider extends ImageProvider<PhotoProvider> {
  PhotoProvider({
    required this.mediumId,
    this.mimeType,
  });

  final String mediumId;
  final String? mimeType;

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

  Future<ui.Codec> _loadAsync(PhotoProvider key, ImageDecoderCallback decode) async {
    assert(key == this);
    final file = await PhotoGallery.getFile(
        mediumId: mediumId, mediumType: MediumType.image, mimeType: mimeType);
    final bytes = await file.readAsBytes();
    ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  Future<PhotoProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PhotoProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final PhotoProvider typedOther = other;
    return mediumId == typedOther.mediumId;
  }

  @override
  int get hashCode => mediumId.hashCode;

  @override
  String toString() => '$runtimeType("$mediumId")';
}
