part of '../../photo_gallery.dart';

/// A list of media with pagination support.
@immutable
class MediaPage {
  /// The album that belongs to
  final Album album;

  /// The start offset for those media.
  final int start;

  /// The current items.
  final List<Medium> items;

  /// Whether using light weight option
  final bool? lightWeight;

  /// The end index in the album.
  int get end => start + items.length;

  ///Indicates whether this page is the last in the album.
  bool get isLast => end >= album.count;

  /// Creates a range of media from platform channel protocol.
  MediaPage.fromJson(this.album, dynamic json, {this.lightWeight})
      : start = json['start'] ?? 0,
        items = json['items'].map<Medium>((x) => Medium.fromJson(x)).toList();

  /// Gets the next page of media in the album.
  Future<MediaPage> nextPage() {
    assert(!isLast);
    return PhotoGallery._listMedia(
      album: album,
      skip: end,
      take: items.length,
      lightWeight: lightWeight,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaPage &&
          runtimeType == other.runtimeType &&
          album == other.album &&
          start == other.start &&
          listEquals(items, other.items);

  @override
  int get hashCode => album.hashCode ^ start.hashCode ^ items.hashCode;

  @override
  String toString() {
    return 'MediaPage{album: $album, '
        'start: $start, '
        'items: $items}';
  }
}
