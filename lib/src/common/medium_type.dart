part of '../../photo_gallery.dart';

/// A medium type.
enum MediumType {
  /// MediumType.image
  image,

  /// MediumType.video
  video,
}

/// Convert MediumType to String
String? mediumTypeToJson(MediumType? value) {
  switch (value) {
    case MediumType.image:
      return 'image';
    case MediumType.video:
      return 'video';
    default:
      return null;
  }
}

/// Parse String to MediumType
MediumType? jsonToMediumType(String? value) {
  switch (value) {
    case 'image':
      return MediumType.image;
    case 'video':
      return MediumType.video;
    default:
      return null;
  }
}
