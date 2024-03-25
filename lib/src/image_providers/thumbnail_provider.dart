part of '../../photo_gallery.dart';

/// Fetches the given medium thumbnail from the gallery.
class ThumbnailProvider extends ImageProvider<ThumbnailProvider> {
  /// ImageProvider of medium thumbnail
  const ThumbnailProvider({
    required this.mediumId,
    this.mediumType,
    this.height,
    this.width,
    this.highQuality = false,
  });

  /// Medium id
  final String mediumId;

  /// Medium type
  final MediumType? mediumType;

  /// Height of medium thumbnail
  final int? height;

  /// Width of medium thumbnail
  final int? width;

  /// Whether using high quality of medium thumbnail
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

  Future<ui.Codec> _loadAsync(
    ThumbnailProvider key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);
    late ui.ImmutableBuffer buffer;
    try {
      final data = await PhotoGallery.getThumbnail(
        mediumId: mediumId,
        mediumType: mediumType,
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
  Future<ThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ThumbnailProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final typedOther = other as ThumbnailProvider;
    return mediumId == typedOther.mediumId;
  }

  @override
  int get hashCode => mediumId.hashCode;

  @override
  String toString() => '$runtimeType("$mediumId")';
}
