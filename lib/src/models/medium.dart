part of photogallery;

/// A medium in the gallery.
///
/// It can be of image or video [mediumType].
@immutable
class Medium {
  /// A unique identifier for the medium.
  final String id;

  /// The medium type.
  final MediumType mediumType;

  /// The medium width.
  final int width;

  /// The medium height.
  final int height;

  /// The date at which the photo or video was taken.
  final DateTime creationDate;

  /// The date at which the photo or video was modified.
  final DateTime modifiedDate;

  Medium({
    this.id,
    this.mediumType,
    this.width,
    this.height,
    this.creationDate,
    this.modifiedDate,
  });

  /// Creates a medium from platform channel protocol.
  Medium.fromJson(dynamic json)
      : id = json["id"],
        mediumType = jsonToMediumType(json["mediumType"]),
        width = json["width"],
        height = json["height"],
        creationDate = json['creationDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['creationDate'])
            : null,
        modifiedDate = json['modifiedDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['modifiedDate'])
            : null;

  static Medium fromMap(Map map) {
    return Medium(
      id: map['id'],
      mediumType: jsonToMediumType(map['mediumType']),
      width: map['width'],
      height: map['height'],
      creationDate: map['creationDate'],
      modifiedDate: map['modifiedDate'],
    );
  }

  Map toMap() {
    return {
      "id": this.id,
      "mediumType": mediumTypeToJson(this.mediumType),
      "height": this.height,
      "width": this.width,
      "creationDate": this.creationDate,
      "modifiedDate": this.modifiedDate,
    };
  }

  /// Get a JPEG thumbnail's data for this medium.
  Future<List<int>> getThumbnail({
    int width,
    int height,
    bool highQuality = false,
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
          mediumType == other.mediumType &&
          width == other.width &&
          height == other.height &&
          creationDate == other.creationDate &&
          modifiedDate == other.modifiedDate;

  @override
  int get hashCode =>
      id.hashCode ^
      mediumType.hashCode ^
      width.hashCode ^
      height.hashCode ^
      creationDate.hashCode ^
      modifiedDate.hashCode;

  @override
  String toString() {
    return 'Medium{id: $id, '
        'mediumType: $mediumType, '
        'width: $width, '
        'height: $height, '
        'creationDate: $creationDate, '
        'modifiedDate: $modifiedDate}';
  }
}
