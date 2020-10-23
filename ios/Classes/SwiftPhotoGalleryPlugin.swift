import Foundation
import MobileCoreServices
import Flutter
import UIKit
import Photos

public class SwiftPhotoGalleryPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "photo_gallery", binaryMessenger: registrar.messenger())
    let instance = SwiftPhotoGalleryPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "listAlbums") {
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let mediumType = arguments["mediumType"] as! String
      result(listAlbums(mediumType: mediumType))
    }
    else if(call.method == "listMedia") {
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let albumId = arguments["albumId"] as! String
      let mediumType = arguments["mediumType"] as! String
      let skip = arguments["skip"] as? NSNumber
      let take = arguments["take"] as? NSNumber
      result(listMedia(albumId: albumId, skip: skip, take: take, mediumType: mediumType))
    }
    else if(call.method == "getMedium") {
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let mediumId = arguments["mediumId"] as! String
      getMedium(
        mediumId: mediumId,
        completion: { (data: [String: Any?]?, error: Error?) -> Void in
          result(data)
      })
    }
    else if(call.method == "getThumbnail") {
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let mediumId = arguments["mediumId"] as! String
      let width = arguments["width"] as? NSNumber
      let height = arguments["height"] as? NSNumber
      let highQuality = arguments["highQuality"] as? Bool
      getThumbnail(
        mediumId: mediumId,
        width: width,
        height: height,
        highQuality: highQuality,
        completion: { (data: Data?, error: Error?) -> Void in
          result(data)
      })
    }
    else if(call.method == "getAlbumThumbnail") {
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let albumId = arguments["albumId"] as! String
      let mediumType = arguments["mediumType"] as? String
      let width = arguments["width"] as? Int
      let height = arguments["height"] as? Int
      let highQuality = arguments["highQuality"] as? Bool
      getAlbumThumbnail(
        albumId: albumId,
        mediumType: mediumType,
        width: width,
        height: height,
        highQuality: highQuality,
        completion: { (data: Data?, error: Error?) -> Void in
          result(data)
      })
    }
    else if(call.method == "getFile") {
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let mediumId = arguments["mediumId"] as! String
      let raw = arguments["raw"] as? Bool
      let autoExtension = arguments["autoExtension"] as? Bool
      getFile(
        mediumId: mediumId,
        raw: raw ?? false,
        autoExtension: autoExtension ?? false,
        completion: { (filepath: String?, error: Error?) -> Void in
          result(filepath?.replacingOccurrences(of: "file://", with: ""))
      })
    }
    else if(call.method == "clear") {
      clearRootExportPath()
      result("")
    }
    else {
      result(FlutterMethodNotImplemented)
    }
  }
  
  private var assetCollections : [PHAssetCollection]  = []
  
  private func listAlbums(mediumType: String) -> [NSDictionary] {
    self.assetCollections = []
    let fetchOptions = PHFetchOptions()
    var total = 0
    var albums = [NSDictionary]()
    var albumIds = Set<String>()
    
    func addCollection (collection: PHAssetCollection, hideIfEmpty: Bool) -> Void {
      let kRecentlyDeletedCollectionSubtype = PHAssetCollectionSubtype(rawValue: 1000000201)
      guard collection.assetCollectionSubtype != kRecentlyDeletedCollectionSubtype else { return }
      
      // De-duplicate by id.
      let albumId = collection.localIdentifier
      guard !albumIds.contains(albumId) else { return }
      albumIds.insert(albumId)
      
      let options = PHFetchOptions()
      options.predicate = self.predicateFromMediumType(mediumType: mediumType)
      if #available(iOS 9, *) {
        fetchOptions.fetchLimit = 1
      }
      let count = PHAsset.fetchAssets(in: collection, options: options).count
      if(count > 0 || !hideIfEmpty) {
        total+=count
        self.assetCollections.append(collection)
        albums.append([
          "id": collection.localIdentifier,
          "mediumType": mediumType,
          "name": collection.localizedTitle ?? "Unknown",
          "count": count,
        ])
      }
    }
    
    func processPHAssetCollections(fetchResult: PHFetchResult<PHAssetCollection>, hideIfEmpty: Bool) -> Void {
      fetchResult.enumerateObjects { (assetCollection, _, _) in
        addCollection(collection: assetCollection, hideIfEmpty: hideIfEmpty)
      }
    }
    
    func processPHCollections (fetchResult: PHFetchResult<PHCollection>, hideIfEmpty: Bool) -> Void {
      fetchResult.enumerateObjects { (collection, _, _) in
        if let assetCollection = collection as? PHAssetCollection {
          addCollection(collection: assetCollection, hideIfEmpty: hideIfEmpty)
        } else if let collectionList = collection as? PHCollectionList {
          processPHCollections(fetchResult: PHCollectionList.fetchCollections(in: collectionList, options: nil), hideIfEmpty: hideIfEmpty)
        }
      }
    }
    
    // Smart Albums.
    processPHAssetCollections(
      fetchResult: PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: fetchOptions),
      hideIfEmpty: true
    )
    
    // User-created collections.
    processPHCollections(
      fetchResult: PHAssetCollection.fetchTopLevelUserCollections(with: fetchOptions),
      hideIfEmpty: true
    )
    
    albums.insert([
      "id": "__ALL__",
      "mediumType": mediumType,
      "name": "All",
      "count" : countMedia(collection: nil, mediumTypes: [mediumType]),
    ], at: 0)
    
    return albums
  }
  
  private func countMedia(collection: PHAssetCollection?, mediumTypes: [String]) -> Int {
    let options = PHFetchOptions()
    options.predicate = self.predicateFromMediumTypes(mediumTypes: mediumTypes)
    if(collection == nil) {
      return PHAsset.fetchAssets(with: options).count
    }
    
    return PHAsset.fetchAssets(in: collection!, options: options).count
  }
  
  private func listMedia(albumId: String, skip: NSNumber?, take: NSNumber?, mediumType: String) -> NSDictionary {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.predicate = predicateFromMediumType(mediumType: mediumType)
    
    let collection = self.assetCollections.first(where: { (collection) -> Bool in
      collection.localIdentifier == albumId
    })
    
    let fetchResult = albumId == "__ALL__"
      ? PHAsset.fetchAssets(with: fetchOptions)
      : PHAsset.fetchAssets(in: collection!, options: fetchOptions)
    let start = skip?.intValue ?? 0
    let total = fetchResult.count
    let end = take == nil ? total : min(start + take!.intValue, total)
    var items = [[String: Any?]]()
    for index in start..<end {
      let asset = fetchResult.object(at: index) as PHAsset
      items.append(getMediumFromAsset(asset: asset))
    }
    
    return [
      "start": start,
      "total": total,
      "items": items,
    ]
  }
  
  private func getMedium(mediumId: String, completion: @escaping ([String : Any?]?, Error?) -> Void) {
    let fetchOptions = PHFetchOptions()
    if #available(iOS 9, *) {
      fetchOptions.fetchLimit = 1
    }
    let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [mediumId], options: fetchOptions)
    
    if (assets.count > 0) {
      let asset: PHAsset = assets[0]
      completion(getMediumFromAsset(asset: asset), nil)
      return
    }
    
    completion(nil, NSError(domain: "photo_gallery", code: 404, userInfo: nil))
  }
  
  private func getThumbnail(
    mediumId: String,
    width: NSNumber?,
    height: NSNumber?,
    highQuality: Bool?,
    completion: @escaping (Data?, Error?) -> Void
  ) {
    let manager = PHImageManager.default()
    let fetchOptions = PHFetchOptions()
    if #available(iOS 9, *) {
      fetchOptions.fetchLimit = 1
    }
    let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [mediumId], options: fetchOptions)
    
    if (assets.count > 0) {
      let asset: PHAsset = assets[0]
      
      let options = PHImageRequestOptions()
      options.isSynchronous = false
      options.version = .current
      options.deliveryMode = (highQuality ?? false) ? .highQualityFormat : .fastFormat
      options.isNetworkAccessAllowed = true
      
      let imageSize = CGSize(width: width?.intValue ?? 128, height: height?.intValue ?? 128)
      manager.requestImage(
        for: asset,
        targetSize: CGSize(width: imageSize.width *  UIScreen.main.scale, height: imageSize.height *  UIScreen.main.scale),
        contentMode: PHImageContentMode.aspectFill,
        options: options,
        resultHandler: {(uiImage: UIImage?, info) in
          guard let image = uiImage else {
            completion(nil , NSError(domain: "photo_gallery", code: 404, userInfo: nil))
            return
          }
          let bytes = image.jpegData(compressionQuality: CGFloat(70))
          completion(bytes, nil)
      })
      return
    }
    
    completion(nil , NSError(domain: "photo_gallery", code: 404, userInfo: nil))
  }
  
  private func getAlbumThumbnail(
    albumId: String,
    mediumType: String?,
    width: Int?,
    height: Int?,
    highQuality: Bool?,
    completion: @escaping (Data?, Error?) -> Void
  ) {
    let manager = PHImageManager.default()
    let fetchOptions = PHFetchOptions()
    if (mediumType != nil) {
      fetchOptions.predicate = self.predicateFromMediumType(mediumType: mediumType!)
    }
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    if #available(iOS 9, *) {
      fetchOptions.fetchLimit = 1
    }
    
    let assets = albumId == "__ALL__" ?
      PHAsset.fetchAssets(with: fetchOptions) :
      PHAsset.fetchAssets(in: self.assetCollections.first(where: { (collection) -> Bool in
        collection.localIdentifier == albumId
      })!, options: fetchOptions)
    
    if (assets.count > 0) {
      let asset: PHAsset = assets[0]
      
      let options = PHImageRequestOptions()
      options.isSynchronous = false
      options.version = .current
      options.deliveryMode = (highQuality ?? false) ? .highQualityFormat : .fastFormat
      options.isNetworkAccessAllowed = true
      
      let imageSize = CGSize(width: width ?? 128, height: height ?? 128)
      manager.requestImage(
        for: asset,
        targetSize: CGSize(
          width: imageSize.width *  UIScreen.main.scale,
          height: imageSize.height *  UIScreen.main.scale
        ),
        contentMode: PHImageContentMode.aspectFill,
        options: options,
        resultHandler: {(uiImage: UIImage?, info) in
          guard let image = uiImage else {
            completion(nil , NSError(domain: "photo_gallery", code: 404, userInfo: nil))
            return
          }
          let bytes = image.jpegData(compressionQuality: CGFloat(80))
          completion(bytes, nil)
      })
      return
    }
    
    completion(nil , NSError(domain: "photo_gallery", code: 404, userInfo: nil))
  }
  
  private func getFile(mediumId: String, raw: Bool, autoExtension: Bool, completion: @escaping (String?, Error?) -> Void) {
    let manager = PHImageManager.default()
    
    let fetchOptions = PHFetchOptions()
    if #available(iOS 9, *) {
      fetchOptions.fetchLimit = 1
    }
    let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [mediumId], options: fetchOptions)
    
    if (assets.count > 0) {
      let asset: PHAsset = assets[0]
      if(asset.mediaType == PHAssetMediaType.image) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        manager.requestImageData(
          for: asset,
          options: options,
          resultHandler: { (data: Data?, uti: String?, orientation, info) in
            DispatchQueue.main.async(execute: {
              guard let originalData = data else {
                completion(nil, NSError(domain: "photo_gallery", code: 404, userInfo: nil))
                return
              }
              var dataToWrite: Data
              var fileExt: String
              if raw {
                dataToWrite = originalData
                fileExt = ""
              } else {
                let dataUTType = self.toSwiftImageUTType(data: originalData)
                fileExt = self.toImageFileExtension(utType: dataUTType)
                if (dataUTType == kUTTypeGIF as String) {
                  dataToWrite = originalData
                } else {
                  guard let imageData = self.convertToImageData(originalData: originalData, utType: dataUTType) else {
                    completion(nil, NSError(domain: "photo_gallery", code: 500, userInfo: nil))
                    return
                  }
                  dataToWrite = imageData
                }
              }
              // Writing to file
              let filepath = self.exportPathForAsset(asset: asset, ext: fileExt)
              try! dataToWrite.write(to: filepath, options: .atomic)
              completion(filepath.absoluteString, nil)
            })
        })
      } else if(asset.mediaType == PHAssetMediaType.video
        || asset.mediaType == PHAssetMediaType.audio) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        manager.requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset, avAudioMix, info) in
          DispatchQueue.main.async(execute: {
            do {
              let avAsset = avAsset as? AVURLAsset
              let data = try Data(contentsOf: avAsset!.url)
              var fileExtenstion = ".mov"
              if let uniformTypeIdentifier = self.uniformTypeIdentifierOf(asset: asset) {
                if let ext = UTTypeCopyPreferredTagWithClass(uniformTypeIdentifier as CFString, kUTTagClassFilenameExtension as CFString)?.takeRetainedValue() as String? {
                  fileExtenstion = ext
                }
              }
              let filepath = self.exportPathForAsset(asset: asset, ext: fileExtenstion)
              try! data.write(to: filepath, options: .atomic)
              completion(filepath.absoluteString, nil)
            } catch {
              completion(nil, NSError(domain: "photo_gallery", code: 500, userInfo: nil))
            }
          })
        })
      }
    }
  }
  
  private func getMediumFromAsset(asset: PHAsset) -> [String: Any?] {
    
    var mimeType: String?
    var assetUTI: String?
    if let uniformTypeIdentifier = uniformTypeIdentifierOf(asset: asset) {
      mimeType = UTTypeCopyPreferredTagWithClass(uniformTypeIdentifier as CFString, kUTTagClassMIMEType as CFString)?.takeRetainedValue() as String?
      assetUTI = uniformTypeIdentifier
    }
    return [
      "id": asset.localIdentifier,
      "mediumType": toDartMediumType(value: asset.mediaType),
      "mime": mimeType ?? "",
      "assetUTI": assetUTI ?? "",
      "height": asset.pixelHeight,
      "width": asset.pixelWidth,
      "duration": NSInteger(asset.duration * 1000),
      "creationDate": (asset.creationDate != nil) ? NSInteger(asset.creationDate!.timeIntervalSince1970 * 1000) : nil,
      "modifiedDate": (asset.modificationDate != nil) ? NSInteger(asset.modificationDate!.timeIntervalSince1970 * 1000) : nil
    ]
  }
  
  private func uniformTypeIdentifierOf(asset: PHAsset) -> String? {
    if #available(iOS 9, *) {
      let resourceList = PHAssetResource.assetResources(for: asset)
      if let resource = resourceList.first {
        return resource.uniformTypeIdentifier
      }
    }
    return asset.value(forKey: "uniformTypeIdentifier") as? String
  }
  
  /// Converts to JPEG/PNG/GIF, and keep EXIF data.
  private func convertToImageData(originalData: Data, utType: String) -> Data? {
    
    let originalSrc = CGImageSourceCreateWithData(originalData as CFData, nil)!
    let options = [kCGImageSourceShouldCache as String: kCFBooleanFalse]
    let originalMetadata = CGImageSourceCopyPropertiesAtIndex(originalSrc, 0, options as CFDictionary)
    
    var compressedImageData: Data?
    if (utType == kUTTypePNG as String) {
      guard let image: UIImage = UIImage(data: originalData) else { return nil }
      compressedImageData = image.pngData()
    } else {
      guard let image: UIImage = UIImage(data: originalData) else { return nil }
      compressedImageData = image.jpegData(compressionQuality: 1.0)
    }
    guard let imageData = compressedImageData else { return nil }
    
    let src = CGImageSourceCreateWithData(imageData as CFData, nil)!
    let data = NSMutableData()
    let uti = CGImageSourceGetType(src)!
    let dest = CGImageDestinationCreateWithData(data as CFMutableData, uti, 1, nil)!
    CGImageDestinationAddImageFromSource(dest, src, 0, originalMetadata)
    if !CGImageDestinationFinalize(dest) { return nil }
    
    return data as Data
  }
  
  private func rootExportPath() -> URL {
    let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    let cacheFolder = paths[0].appendingPathComponent("photo_gallery")
    try! FileManager.default.createDirectory(at: cacheFolder, withIntermediateDirectories: true, attributes: nil)
    return cacheFolder;
  }
  
  private func clearRootExportPath() {
    try! FileManager.default.removeItem(atPath: rootExportPath().absoluteString)
  }
  
  private func exportPathForAsset(asset: PHAsset, ext: String) -> URL {
    let mediumId = asset.localIdentifier
      .replacingOccurrences(of: "/", with: "__")
      .replacingOccurrences(of: "\\", with: "__")
    return rootExportPath().appendingPathComponent(mediumId+ext)
  }
  
  private func toSwiftImageUTType(data: Data) -> String {
    var values = [UInt8](repeating:0, count:1)
    data.copyBytes(to: &values, count: 1)

    let ext: String
    switch (values[0]) {
    case 0xFF:
      ext = kUTTypeJPEG as String
    case 0x89:
        ext = kUTTypePNG as String
    case 0x47:
        ext = kUTTypeGIF as String
    default:
        ext = kUTTypeJPEG as String
    }
    return ext
  }
  
  private func toImageFileExtension(utType: String) -> String {
    var ext: String = ".jpg"
    if (utType == kUTTypeJPEG as String) {
      ext = ".jpg"
    } else if (utType == kUTTypePNG as String) {
      ext = ".png"
    } else if (utType == kUTTypeGIF as String) {
      ext = ".gif"
    }
    return ext
  }
  
  
  private func toSwiftMediumType(value: String) -> PHAssetMediaType? {
    switch value {
    case "image": return PHAssetMediaType.image
    case "video": return PHAssetMediaType.video
    case "audio": return PHAssetMediaType.audio
    default: return nil
    }
  }
  
  private func toDartMediumType(value: PHAssetMediaType) -> String? {
    switch value {
    case PHAssetMediaType.image: return "image"
    case PHAssetMediaType.video: return "video"
    case PHAssetMediaType.audio: return "audio"
    default: return nil
    }
  }
  
  private func predicateFromMediumTypes(mediumTypes: [String]) -> NSPredicate {
    let predicates = mediumTypes.map { (dartValue) -> NSPredicate in
      return predicateFromMediumType(mediumType: dartValue)
    }
    return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: predicates)
  }
  
  private func predicateFromMediumType(mediumType: String) -> NSPredicate {
    let swiftType = toSwiftMediumType(value: mediumType)
    return NSPredicate(format: "mediaType = %d", swiftType!.rawValue)
  }
}
