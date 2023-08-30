
import GalleryPicker
import Foundation
import UIKit
import SDWebImage

class PixabayMediaItem: MediaItem {
    
    let pixabayMedia: PixabayMedia
    
    init(with pixabayMedia: PixabayMedia, thumbnail: UIImage?) {
        self.pixabayMedia = pixabayMedia
        
        let source: MediaItem.SourceType

        switch pixabayMedia {
        case .video(let video):
            source = .video(TimeInterval(video.duration))
        case .image:
            source = .photo
        }

        super.init(identifier: String(pixabayMedia.id), type: source, size: pixabayMedia.size)
        
        self.thumbnail = thumbnail
        
        
    }
    
}
