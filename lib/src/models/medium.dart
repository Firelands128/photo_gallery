part of photogallery;

/// A medium in the gallery.
///
/// It can be of image or video [mediumType].
// @immutable
class Medium {
  /// A unique identifier for the medium.
  final String id;

  /// The medium filename.
  final String? filename;

  /// The medium title
  final String? title;

  /// The medium type.
  final MediumType? mediumType;

  /// The medium width.
  final int? width;

  /// The medium height.
  final int? height;

  /// The medium size.
  final int? size;

  /// The medium orientation.
  final int? orientation;

  /// The medium mimeType.
  final String? mimeType;

  /// The duration of video
  final int duration;

  /// The date at which the photo or video was taken.
  final DateTime? creationDate;

  /// The date at which the photo or video was modified.
  final DateTime? modifiedDate;

  bool isValid = true;

  Medium({
    required this.id,
    this.filename,
    this.title,
    this.mediumType,
    this.width,
    this.height,
    this.size,
    this.orientation,
    this.mimeType,
    this.duration = 0,
    this.creationDate,
    this.modifiedDate,
  });

  /// Creates a medium from platform channel protocol.
  Medium.fromJson(dynamic json)
      : id = json["id"],
        filename = json["filename"],
        title = json["title"],
        mediumType = jsonToMediumType(json["mediumType"]),
        width = json["width"],
        height = json["height"],
        size = json["size"],
        orientation = json["orientation"],
        mimeType = json["mimeType"],
        duration = json['duration'] ?? 0,
        creationDate = json['creationDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['creationDate'])
            : null,
        modifiedDate = json['modifiedDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['modifiedDate'])
            : null;

  static Medium fromMap(Map map) {
    return Medium(
      id: map['id'],
      filename: map['filename'],
      title: map['title'],
      mediumType: jsonToMediumType(map['mediumType']),
      width: map['width'],
      height: map['height'],
      orientation: map['orientation'],
      mimeType: map["mimeType"],
      creationDate: map['creationDate'],
      modifiedDate: map['modifiedDate'],
    );
  }

  Map toMap() {
    return {
      "id": this.id,
      "filename": this.filename,
      "title": this.title,
      "mediumType": mediumTypeToJson(this.mediumType),
      "height": this.height,
      "orientation": this.orientation,
      "mimeType": this.mimeType,
      "width": this.width,
      "creationDate": this.creationDate,
      "modifiedDate": this.modifiedDate,
    };
  }

  /// Get a JPEG thumbnail's data for this medium.
  Future<List<int>> getThumbnail({
    int? width,
    int? height,
    bool? highQuality = false,
  }) {
    return PhotoGallery.getThumbnail(
      mediumId: id,
      width: width,
      height: height,
      mediumType: mediumType,
      highQuality: highQuality,
    );
  }

  /// Get the original file.
  Future<File> getFile() {
    return PhotoGallery.getFile(
      mediumId: id,
      mediumType: mediumType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medium &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          filename == other.filename &&
          title == other.title &&
          mediumType == other.mediumType &&
          width == other.width &&
          height == other.height &&
          orientation == other.orientation &&
          mimeType == other.mimeType &&
          creationDate == other.creationDate &&
          modifiedDate == other.modifiedDate;

  @override
  int get hashCode =>
      id.hashCode ^
      filename.hashCode ^
      title.hashCode ^
      mediumType.hashCode ^
      width.hashCode ^
      height.hashCode ^
      orientation.hashCode ^
      mimeType.hashCode ^
      creationDate.hashCode ^
      modifiedDate.hashCode;

  @override
  String toString() {
    return 'Medium{id: $id, '
        'filename: $filename, '
        'title: $title, '
        'mediumType: $mediumType, '
        'width: $width, '
        'height: $height, '
        'orientation: $orientation, '
        'mimeType: $mimeType, '
        'creationDate: $creationDate, '
        'modifiedDate: $modifiedDate}';
  }

  void updateIsValide(bool value) {
    isValid = value;
  }
}
