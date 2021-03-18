part of photogallery;

/// A medium type.
enum MediumType {
  image,
  video,
}

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
