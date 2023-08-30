//
//  File.swift
//  
//
//  Created by Anton K on 23.07.2020.
//

import Photos

public final class MediaItemFetchResult {
    public let album: Album
    public var fetchResult: PHFetchResult<PHAsset>

    init(album: Album, fetchResult: PHFetchResult<PHAsset>) {
        self.album = album
        self.fetchResult = fetchResult
    }
}

