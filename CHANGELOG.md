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
