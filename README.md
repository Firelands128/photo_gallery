# Photo Gallery

[![pub package](https://img.shields.io/pub/v/photo_gallery.svg)](https://pub.dev/packages/photo_gallery)

A Flutter plugin that retrieves images and videos from mobile native gallery.

## Installation

First, add photo_gallery as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

#### iOS
Add the following keys to your *Info.plist* file, located in ```<project root>/ios/Runner/Info.plist```:

```NSPhotoLibraryUsageDescription``` - describe why your app needs permission for the photo library. This is called *Privacy - Photo Library Usage Description* in the visual editor.

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Example usage description</string>
```

#### Android
Add the following permissions to your *AndroidManifest.xml*, located in ```<project root>/android/app/src/main/AndroidManifest.xml```:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    ...
<manifest/>
```

API 29+

Add the following property to your *AndroidManifest.xml*, located in ```<project root>/android/app/src/main/AndroidManifest.xml``` to [opt-out of scoped storage](https://developer.android.com/training/data-storage/use-cases#opt-out-scoped-storage):
```xml
<manifest ...>
    ...
    <application
        android:requestLegacyExternalStorage="true"
        ...>
    <application/>
<manifest/>
```

## Usage

* Listing albums in the gallery
```dart
final List<Album> imageAlbums = await PhotoGallery.listAlbums(
    mediumType: mediumType.image,
);
final List<Album> videoAlbums = await PhotoGallery.listAlbums(
    mediumType: mediumType.video,
);
```
* Listing media in an album
```dart
final MediaPage imagePage = await imageAlbum.listMedia(
    skip: 5,
    take: 10,
);
final MediaPage videoPage = await videoAlbum.listMedia(
    newest: false,
    skip: 5,
    take: 10,
);
final List<Medium> allMedia = [
    ...imagePage.items,
    ...videoPage.items,
];
```
* Loading more media in a album
```dart
if (!imagePage.isLast) {
    final nextImagePage = await imagePage.nextPage();
    // ...
}
```
* Getting a file
```dart
final File file = await medium.getFile();
```
```dart
final File file = await PhotoGallery.getFile(mediumId: mediumId);
```
* Getting thumbnail data
```dart
final List<int> data = await medium.getThumbnail();
```
```dart
final List<int> data = await PhotoGallery.getThumbnail(mediumId: mediumId);
```
You can also specify thumbnail width and height on Android API 29 or higher; You can also specify thumbnail width, height and whether provider high quality or not on iOS:
```dart
final List<int> data = await medium.getThumbnail(
    width: 128,
    height: 128,
    highQuality: true,
);
```
```dart
final List<int> data = await PhotoGallery.getThumbnail(
    mediumId: mediumId,
    mediumType: MediumType.image,
    width: 128,
    height: 128,
    highQuality: true,
);
```
* Getting album thumbnail data
```dart
final List<int> data = await album.getThumbnail();
```
```dart
final List<int> data = await PhotoGallery.getAlbumThumbnail(albumId: albumId);
```
You can also specify thumbnail width and height on Android API 29 or higher; You can also specify thumbnail width, height and whether provider high quality or not on iOS:
```dart
final List<int> data = await album.getThumbnail(
    width: 128,
    height: 128,
    highQuality: true,
);
```
```dart
final List<int> data = await PhotoGallery.getAlbumThumbnail(
    albumId: albumId,
    width: 128,
    height: 128,
    highQuality: true,
);
```
* Displaying medium thumbnail

ThumbnailProvider are available to display thumbnail images (here with the help of dependency [transparent_image](https://pub.dev/packages/transparent_image)):

```dart
FadeInImage(
    fit: BoxFit.cover,
    placeholder: MemoryImage(kTransparentImage),
    image: ThumbnailProvider(
        mediumId: mediumId,
        mediumType: MediumType.image,
        width: 128,
        height: 128,
        hightQuality: true,
    ),
)
```
Width and height is only available on Android API 29+ or iOS platform
* Displaying album thumbnail

AlbumThumbnailProvider are available to display album thumbnail images (here with the help of dependency [transparent_image](https://pub.dev/packages/transparent_image)):
```dart
FadeInImage(
    fit: BoxFit.cover,
    placeholder: MemoryImage(kTransparentImage),
    image: AlbumThumbnailProvider(
        albumId: albumId,
        width: 128,
        height: 128,
        hightQuality: true,
    ),
)
```
Width and height is only available on Android API 29+ or iOS platform. High quality is only available on iOS platform.
* Displaying a full size image

You can use PhotoProvider to display the full size image (here with the help of dependency [transparent_image](https://pub.dev/packages/transparent_image)):

```dart
FadeInImage(
    fit: BoxFit.cover,
    placeholder: MemoryImage(kTransparentImage),
    image: PhotoProvider(
        mediumId: mediumId,
    ),
)
```
