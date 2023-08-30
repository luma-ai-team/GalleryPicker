//
//  AssetsManager.swift
//  RMPhotoNavBar
//
//  Created by Roi Mulia on 7/19/17.
//  Copyright © 2017 Roi Mulia. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import Foundation
import PhotosUI
import PermissionKit

public final class GalleryAssetService: NSObject {
    public typealias ImageCompletion = (UIImage?) -> Void
    public typealias AssetCompletion = (AVAsset?) -> Void
    public typealias MixedCompletion = ([MediaContentFetchResult]) -> Void
    public typealias ProgressHandler = (MediaItem, Float) -> Void

    public enum Error: Swift.Error {
        case noData
        case unsupportedContent(AnyClass)
    }

    public static var shared: GalleryAssetService = .init()

    private lazy var library: PHPhotoLibrary = .shared()
    private lazy var manager: PHCachingImageManager = .init()
    private lazy var queue: DispatchQueue = .init(label: "media-library", qos: .userInteractive)
    private let thumbnailCache: NSCache<NSString, UIImage> = .init()
    private var pendingRequestID: PHImageRequestID?
    private weak var pendingProgress: Progress?

    private var observers: [WeakRef<Observer>] = []
    private var didRegisterPhotoLibraryObserver: Bool = false

    // MARK: - Albums

    public func fetchAlbums(filter: MediaItemFilter = .init(), completion: @escaping ([Album]) -> Void) {
        queue.async {
            var albums: [Album] = []

            let options = filter.fetchOptions
            func handle(_ collection: PHAssetCollection) {
                let isUserLibrary = collection.assetCollectionSubtype == .smartAlbumUserLibrary
                let album = Album(collection: collection, title: nil)
                album.estimatedAssetCount = PHAsset.fetchAssets(in: collection, options: options).count

                if album.estimatedAssetCount != 0 {
                    if isUserLibrary {
                        albums.insert(album, at: 0)
                    }
                    else {
                        albums.append(album)
                    }
                }
            }

            let smartAlbumCollectionResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                                     subtype: .any,
                                                                                     options: nil)
            smartAlbumCollectionResult.enumerateObjects { (collection: PHAssetCollection, _, _) in
                handle(collection)
            }

            let albumCollectionsResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            albumCollectionsResult.enumerateObjects { (collection: PHAssetCollection, _, _) in
                handle(collection)
            }

            DispatchQueue.main.async {
                completion(albums)
            }
        }
    }

    public func fetchMediaItemList(in album: Album,
                                   filter: MediaItemFilter = .init(),
                                   completion: @escaping (MediaItemFetchResult) -> Void) {
        queue.async {
            let identifiers = [album.identifier]
            guard let assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: identifiers,
                                                                                options: nil).firstObject else {
                return
            }

            let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: filter.fetchOptions)
            DispatchQueue.main.async {
                completion(.init(album: album, fetchResult: fetchResult))
            }
        }
    }

    // MARK: - Thumbnails

    public func fetchThumbnail(for item: MediaItem, size: CGSize, completion: @escaping ImageCompletion) {
        if let thumbnail = item.thumbnail {
            completion(thumbnail)
            return
        }

        if let asset = item.asset {
            return fetchThumbnail(for: asset, size: size, completion: { (image: UIImage?) in
                item.thumbnail = image
                completion(image)
            })
        }
        
        queue.async {
            guard let asset = self.fetchAsset(for: item) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.fetchThumbnail(for: asset, size: size) { (image: UIImage?) in
                item.thumbnail = image
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    public func fetchThumbnail(for album: Album, size: CGSize, filter: MediaItemFilter = .init(), completion: @escaping ImageCompletion) {
        if let thumbnail = album.thumbnail {
            completion(thumbnail)
            return
        }

        queue.async {
            guard let assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [album.identifier],
                                                                                options: nil).firstObject else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let posterAsset: PHAsset?
            if assetCollection.assetCollectionType == .smartAlbum ||
               assetCollection.assetCollectionSubtype == .albumMyPhotoStream {
                posterAsset = PHAsset.fetchAssets(in: assetCollection, options: filter.fetchOptions).lastObject
            }
            else {
                posterAsset = PHAsset.fetchAssets(in: assetCollection, options: filter.fetchOptions).firstObject
            }

            guard let asset = posterAsset else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.fetchThumbnail(for: asset, size: size) { (image: UIImage?) in
                album.thumbnail = image
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    // MARK: - Data

    public func isItemExistsInDeviceLibrary(_ item: MediaItem) -> Bool {
        return fetchAsset(for: item) != nil
    }

    public func fetchContent(for items: [MediaItem], progressHandler: @escaping ProgressHandler, completion: @escaping MixedCompletion) {
        let semaphore = DispatchSemaphore(value: 0)
        let totalProgress = Float(items.count)
        var result: [MediaContentFetchResult] = []
        queue.async {
            for (index, item) in items.enumerated() {
                let itemProgressHandler = { (item: MediaItem, progress: Float) in
                    progressHandler(item, (Float(index) + progress) / totalProgress)
                }

                if item.type.isVideo {
                    self.fetchVideoAsset(for: item, progressHandler: itemProgressHandler) { (asset: AVAsset?) in
                        if let asset = asset {
                            result.append(.asset(asset))
                        }
                        else {
                            result.append(.error(Error.noData))
                        }

                        semaphore.signal()
                    }
                }
                else {
                    self.fetchImage(for: item, progressHandler: itemProgressHandler) { (image: UIImage?) in
                        if let image = image {
                            result.append(.image(image))
                        }
                        else {
                            result.append(.error(Error.noData))
                        }
                        
                        semaphore.signal()
                    }
                }

                semaphore.wait()

                if self.pendingRequestID == nil {
                    break
                }
            }
            
            while result.count < items.count {
                result.append(.error(Error.noData))
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    public func cancelContentPendingContentFetches() {
        cancelPendingRequest()
    }

    public func fetchImage(for item: MediaItem, progressHandler: @escaping ProgressHandler, completion: @escaping ImageCompletion) {

        if #available(iOS 14, *),
           let pickerResult = item.content as? PHPickerResult {
            return fetchResult(for: item, result: pickerResult, progressHandler: progressHandler, completion: completion)
        }
        else if item.content != nil {
            return completion(nil)
        }

        guard let asset = fetchAsset(for: item) else {
            completion(nil)
            return
        }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.progressHandler = { (progress: Double, _, _, _) in
            DispatchQueue.main.async {
                progressHandler(item, Float(progress))
            }
        }

        pendingRequestID = manager.requestImageDataAndOrientation(for: asset, options: requestOptions, resultHandler: { (imageData: Data?, _, _, _) in
            guard let data = imageData else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        })
    }

    public func fetchVideoAsset(for item: MediaItem, progressHandler: @escaping ProgressHandler, completion: @escaping AssetCompletion) {

        if #available(iOS 14, *),
           let pickerResult = item.content as? PHPickerResult {
            if item.type.isLivePhoto {
                return fetchResult(for: item,
                                   result: pickerResult,
                                   progressHandler: progressHandler,
                                   completion: { [weak self] (photo: PHLivePhoto?) in
                    guard let photo = photo else {
                        return completion(nil)
                    }
                    self?.fetchLivePhotoContent(for: photo, completion: completion)
                })
            }
            else if item.type.isVideo {
                var progressTimer: Timer?
                let progress = pickerResult.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier,
                                                                                completionHandler: { (url: URL?, error: Swift.Error?) in
                    progressTimer?.invalidate()
                    progressTimer = nil

                    guard let url = url else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }

                    let targetURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.removeItem(at: targetURL)
                    try? FileManager.default.copyItem(at: url, to: targetURL)

                    DispatchQueue.main.async {
                        completion(AVAsset(url: targetURL))
                    }
                })

                pendingProgress = progress
                DispatchQueue.main.async {
                    progressTimer = Timer(fire: .init(timeIntervalSinceNow: 0.25), interval: 0.25, repeats: true) { _ in
                        progressHandler(item, Float(progress.fractionCompleted))
                    }
                    if let progressTimer = progressTimer {
                        RunLoop.current.add(progressTimer, forMode: .common)
                    }
                }
                return
            }
        }
        else if item.content != nil {
            return completion(nil)
        }

        guard let asset = fetchAsset(for: item) else {
            completion(nil)
            return
        }

        if item.type.isUnknown {
            item.type = MediaItem.mediaItemType(for: asset)
        }

        if item.type.isVideo {
            let requestOptions = PHVideoRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.progressHandler = { (progress: Double, _, _, _) in
                DispatchQueue.main.async {
                    progressHandler(item, Float(progress))
                }
            }

            pendingRequestID = manager.requestAVAsset(forVideo: asset, options: requestOptions) { (asset: AVAsset?, _, _) in
                DispatchQueue.main.async {
                    completion(asset)
                }
            }
        }
        else if item.type.isLivePhoto {
            let requestOptions = PHLivePhotoRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.progressHandler = { (progress: Double, _, _, _) in
                DispatchQueue.main.async {
                    progressHandler(item, Float(progress))
                }
            }

            pendingRequestID = manager.requestLivePhoto(for: asset,
                                                        targetSize: .zero,
                                                        contentMode: .default,
                                                        options: requestOptions) { [weak self] (photo: PHLivePhoto?, _) in
                guard let photo = photo else {
                    return completion(nil)
                }

                self?.fetchLivePhotoContent(for: photo, completion: completion)
            }
        }
        else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    public func cancelPendingRequest() {
        if let requestID = pendingRequestID {
            manager.cancelImageRequest(requestID)
            pendingRequestID = nil
        }

        pendingProgress?.cancel()
        pendingProgress = nil
    }

    // MARK: - Observing

    func observe(_ target: Observer) {
        var hasAnyAuthorization = false
        let authorizationStatus = PhotoLibraryPermission.currentStatus(for: .readWrite)
        hasAnyAuthorization = authorizationStatus == .authorized || authorizationStatus == .limited
        
        guard hasAnyAuthorization else {
            return
        }
        
        if didRegisterPhotoLibraryObserver == false {
            PHPhotoLibrary.shared().register(self)
            didRegisterPhotoLibraryObserver = true
        }

        let isSubscribed = observers.contains(where: { (observer: WeakRef<Observer>) -> Bool in
            return observer.object === target
        })
        if isSubscribed == false {
            observers.append(weak: target)
        }
    }

    // MARK: - Private

    @available(iOS 14, *)
    private func fetchResult<T: NSItemProviderReading>(for item: MediaItem,
                                                       result: PHPickerResult,
                                                       progressHandler: @escaping ProgressHandler,
                                                       completion: @escaping (T?) -> Void) {

        guard result.itemProvider.canLoadObject(ofClass: T.self) else {
            return completion(nil)
        }

        var progressTimer: Timer?
        let progress = result.itemProvider.loadObject(ofClass: T.self) { (object: NSItemProviderReading?, error: Swift.Error?) in
            progressTimer?.invalidate()
            progressTimer = nil

            DispatchQueue.main.async {
                completion(object as? T)
            }
        }

        pendingProgress = progress
        DispatchQueue.main.async {
            progressTimer = Timer(fire: .init(timeIntervalSinceNow: 0.25), interval: 1.0 / 30.0, repeats: true) { _ in
                progressHandler(item, Float(progress.fractionCompleted))
            }
            if let progressTimer = progressTimer {
                RunLoop.current.add(progressTimer, forMode: .common)
            }
        }
    }

    private func fetchLivePhotoContent(for photo: PHLivePhoto, completion: @escaping AssetCompletion) {
        let resources = PHAssetResource.assetResources(for: photo)
        guard let videoResource = resources.first(where: { (resource: PHAssetResource) -> Bool in
            return resource.type == .pairedVideo
        }) else {
            return completion(nil)
        }

        let identifier = videoResource.assetLocalIdentifier.isEmpty ?
            videoResource.originalFilename :
            videoResource.assetLocalIdentifier
        let url =  URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(identifier.replacingOccurrences(of: "/", with: "_"))
            .appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: url)

        let requestOptions = PHAssetResourceRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(for: videoResource,
                                                   toFile: url,
                                                   options: requestOptions,
                                                   completionHandler: { _ in
            DispatchQueue.main.async {
                let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
                completion(asset)
            }
        })
    }

    private func fetchAsset(for item: MediaItem) -> PHAsset? {
        if let asset = item.asset {
            return asset
        }

        let fetchOptions = PHFetchOptions()
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [item.identifier], options: fetchOptions).firstObject
        item.asset = asset
        return asset
    }

    private func fetchThumbnail(for asset: PHAsset, size: CGSize, completion: @escaping ImageCompletion) {
        if let thumbnail = thumbnailCache.object(forKey: asset.localIdentifier as NSString) {
            return completion(thumbnail)
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { [weak self] (image: UIImage?, _) in
            if let image = image {
                self?.thumbnailCache.setObject(image, forKey: asset.localIdentifier as NSString)
            }

            completion(image)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension GalleryAssetService: PHPhotoLibraryChangeObserver {

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.observers.compact().forEach { (observer: WeakRef<Observer>) in
                observer.object?.handler(changeInstance)
            }
        }
    }
}

