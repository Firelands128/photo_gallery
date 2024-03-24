# 2.2.1

Upgrade ```flutter_lints``` dependency, and then lint code according to the ```public_member_api_docs``` and ```use_string_in_part_of_directives``` rule.

Make ```AlbumPageState``` widget private.

## 2.2.0

Add GitHub Actions configuration to automatically publish to ```pub.dev``` from ```Github```.

Add dart-doc on ```PhotoGallery``` APIs.

Fix bugs.

Upgrade versions.

## 2.1.1

Update flutter SDK constraints in pubspec.yaml.

Use flutter_lints to lint code.

Add dartdoc comments for public APIs.

## 2.1.0

Add deleting medium functionality.

Add light weight option of listing media.

Catch exception of getting medium thumbnail failed then show default image.

Add requestLegacyExternalStorage flag back to be compatible with Android 10.

Use photos permission for iOS14+.

Improve performance of getting medium full information on iOS platform.

## 2.0.2

Add some default value of models' property.

## 2.0.1

"DecoderBufferCallback" is deprecated. Use "ImageDecoderCallback" with ImageProvider.loadImage instead.

## 2.0.0

*Breaking changes:
• Move "newest" parameter from "listMedia" to "listAlbums" API
• Move "newest" property from "MediaPage" to "Media"
• Add "newest" parameter of getAlbumThumbnail API
• Update to "album" parameter of AlbumThumbnailProvider
• Update "mediumType" to be optional parameter of "listAlbums" to allow fetch both type of media
• Remove unnecessary "total" parameter of "listMedia" API
• Remove unnecessary "total" property of "MediaPage", use "total" of "Album" instead.

## 1.2.2

Upgrade deprecated code.

Use QUERY_ARG_SQL_SORT_ORDER in contentResolver.query to fix sorting bug after Android 11.

Upgrade Android compileSdkVersion to 33.

## 1.2.1

Change DATE_TAKEN to DATE_ADDED of media column in android code.

Add size property of medium.

Update AndroidManifest.xml with removing requestLegacyExternalStorage flag and SplashScreen meta-data tag.

## 1.2.0

Upgrade versions of flutter, android sdk, kotlin, gradle and so on.

Remove ORIENTATION field of video metadata because it's invalid before Android 10.

Add default album thumbnail to show when album is empty.

## 1.1.1

Fix a bug that "newest" argument is not working on Android 29 or below.

Add "filename" and "title" property of Medium.

## 1.1.0

Use Android contentResolver Bundle() only on sdk 30+.

Add "orientation" property of Medium to meet EXIF standard, but on iOS listing media API don't provide it.

Update album name property to nullable.

## 1.0.1

Add "mimeType" parameter in "getFile" API to allow specifying image format when get full image on both platforms.

Add optional "hideIfEmpty" parameter in "listAlbums" API to show empty albums, only available on iOS platform.

Accept "highQuality" parameter in "getThumbnail" and "getAlbumThumbnail" API on Android platform.

## 1.0.0

Add null safety support.

Add sorting by newest or oldest functionality to ```listMedia``` API.

## 0.4.0

Add ```cleanCache``` api to clean the cache directory.

Add ```mimeType``` attribute of ```Medium```.

Add alternative media query syntax to support Android 11.

Cache original image data to a cached file and keep original medium file extension in iOS.

Fix a problem of collection possibly be nil.

Update .gitignore file.

## 0.3.0

Force ```getFile``` to use high quality format for videos in iOS platform.

Add optional ```mediumType``` parameter of ```getAlbumThumbnail``` api method to display video thumbnail correctly.

## 0.2.5

Remove ```MediumType``` attribute in ```MediaPage```.

Remove ```MediumType``` parameter in ```_listMedia``` method.

## 0.2.4

Add ```VideoProvider``` widget to play video in plugin example.

## 0.2.3

Add ```MediumType``` attribute in ```ThumbnailProvider```.

Fix a bug that throw ```FileNotFountException``` when load image and video thumbnail doesn't exists on Android API 29+.

Change medium ```creationDate``` and ```modifiedDate``` precision from second to millisecond on iOS platform.

Add video duration attribute in ```Medium``.

## 0.2.0+1

Release 0.2.0+1.

## 0.1.1+1

Remove transparent_image dependency out of plugin.

## 0.1.0+1

Initial release.
