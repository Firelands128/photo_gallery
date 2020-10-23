part of photogallery;

/// A album in the gallery.
@immutable
class Album {
  /// A unique identifier for the album.
  final String id;

  /// The [MediumType] of the album.
  final MediumType mediumType;


    /// The [MediumSubtype] of the album.
  final MediumSubtype mediumSubtype;

  /// The name of the album.
  final String name;

  /// The total number of media in the album.
  final int count;

  /// Indicates whether this album contains all media.
  bool get isAllAlbum => id == "__ALL__";

  /// Creates a album from platform channel protocol.
  Album.fromJson(dynamic json)
      : id = json['id'],
        mediumType = jsonToMediumType(json['mediumType']),
        mediumSubtype= jsonToMediumSubtype(json['mediumSubtype']),
        name = json['name'],
        count = json['count'];

  /// list media in the album.
  ///
  /// Pagination can be controlled out of [skip] (defaults to `0`) and
  /// [take] (defaults to `<total>`).
  Future<MediaPage> listMedia({
    int skip,
    int take,
  }) {
    return PhotoGallery._listMedia(
      album: this,
      total: this.count,
      skip: skip,
      take: take,
    );
  }

  /// Get thumbnail data for this album.
  ///
  /// It will display the lastly taken medium thumbnail.
  Future<List<int>> getThumbnail({
    int width,
    int height,
    bool highQuality = false,
  }) {
    return PhotoGallery.getAlbumThumbnail(
      albumId: id,
      mediumType: this.mediumType,
      mediumSubtype: this.mediumSubtype,
      width: width,
      height: height,
      highQuality: highQuality,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mediumType == other.mediumType &&
          name == other.name &&
          count == other.count;

  @override
  int get hashCode =>
      id.hashCode ^ mediumType.hashCode ^ name.hashCode ^ count.hashCode;

  @override
  String toString() {
    return 'Album{id: $id, '
        'mediumType: $mediumType, '
        'name: $name, '
        'count: $count}';
  }
}
