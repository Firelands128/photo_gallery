part of photogallery;

/// A medium type.
enum MediumType {
  image,
  video,
}

String mediumTypeToJson(MediumType value) {
  switch (value) {
    case MediumType.image:
      return 'image';
    case MediumType.video:
      return 'video';
    default:
      return null;
  }
}

MediumType jsonToMediumType(String value) {
  switch (value) {
    case 'image':
      return MediumType.image;
    case 'video':
      return MediumType.video;
    default:
      return null;
  }
}


enum MediumSubtype {
  iOSPhotoLive,
  animatedImage
}

String mediumSubtypeToJson(MediumSubtype value) {
  switch (value) {
    case MediumSubtype.iOSPhotoLive:
      return 'photoLive';
    case MediumSubtype.animatedImage:
      return 'gif';
    default:
      return null;
  }
}

MediumSubtype jsonToMediumSubtype(String value) {
  switch (value) {
    case 'photoLive':
      return MediumSubtype.iOSPhotoLive;
    case 'gif': // Use gif to search by mime in Android without convert
      return MediumSubtype.animatedImage;
    default:
      return null;
  }
}
