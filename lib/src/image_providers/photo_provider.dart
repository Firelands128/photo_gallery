part of photogallery;

/// Fetches the given image from the gallery.
class PhotoProvider extends ImageProvider<PhotoProvider> {
  PhotoProvider({
    required this.mediumId,
  });

  final String mediumId;

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

  Future<ui.Codec> _loadAsync(PhotoProvider key, DecoderCallback decode) async {
    assert(key == this);
    final file = await PhotoGallery.getFile(
        mediumId: mediumId, mediumType: MediumType.image);

    final bytes = await file.readAsBytes();

    return await decode(bytes);
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
