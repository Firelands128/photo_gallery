part of '../../photo_gallery.dart';

/// Fetches the given image from the gallery.
class PhotoProvider extends ImageProvider<PhotoProvider> {
  /// ImageProvider of photo
  PhotoProvider({
    required this.mediumId,
    this.mimeType,
  });

  /// Medium id
  final String mediumId;

  /// Mime type
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

  Future<ui.Codec> _loadAsync(
    PhotoProvider key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);
    final file = await PhotoGallery.getFile(
        mediumId: mediumId, mediumType: MediumType.image, mimeType: mimeType);
    ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromFilePath(file.path);
    return decode(buffer);
  }

  @override
  Future<PhotoProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PhotoProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final typedOther = other as PhotoProvider;
    return mediumId == typedOther.mediumId;
  }

  @override
  int get hashCode => mediumId.hashCode;

  @override
  String toString() => '$runtimeType("$mediumId")';
}
