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
  iOSPhoneLive,
  androidGif
}

String mediumSubtypeToJson(MediumSubtype value) {
  switch (value) {
    case MediumSubtype.iOSPhoneLive:
      return 'phoneLive';
    case MediumSubtype.androidGif:
      return 'gif';
    default:
      return null;
  }
}

MediumSubtype jsonToMediumSubtype(String value) {
  switch (value) {
    case 'phoneLive':
      return MediumSubtype.iOSPhoneLive;
    case 'gif':
      return MediumSubtype.androidGif;
    default:
      return null;
  }
}
