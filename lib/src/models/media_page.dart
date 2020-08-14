part of photogallery;

/// A list of media with pagination support.
@immutable
class MediaPage {
  final Album album;

  /// The medium type of [items].
  final MediumType mediumType;

  /// The start offset for those media.
  final int start;

  /// The total number of items.
  final int total;

  /// The current items.
  final List<Medium> items;

  /// The end index in the album.
  int get end => start + items.length;

  ///Indicates whether this page is the last in the album.
  bool get isLast => end >= total;

  /// Creates a range of media from platform channel protocol.
  MediaPage.fromJson(this.album, this.mediumType, dynamic json)
      : start = json['start'],
        total = json['total'],
        items = json['items'].map<Medium>((x) => Medium.fromJson(x)).toList();

  /// Gets the next page of media in the album.
  Future<MediaPage> nextPage() {
    assert(!isLast);
    return PhotoGallery._listMedia(
      album: album,
      mediumType: mediumType,
      total: total,
      skip: end,
      take: items.length,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaPage &&
          runtimeType == other.runtimeType &&
          album == other.album &&
          mediumType == other.mediumType &&
          start == other.start &&
          total == other.total &&
          listEquals(items, other.items);

  @override
  int get hashCode =>
      album.hashCode ^
      mediumType.hashCode ^
      start.hashCode ^
      total.hashCode ^
      items.hashCode;

  @override
  String toString() {
    return 'MediaPage{album: $album, '
        'mediumType: $mediumType, '
        'start: $start, '
        'total: $total, '
        'items: $items}';
  }
}
