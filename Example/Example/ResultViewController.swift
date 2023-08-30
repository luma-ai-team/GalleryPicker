//
//  Created by Anton K on 28.10.2020.
//  Copyright © 2020 socialkit. All rights reserved.
//

import UIKit
import AVFoundation
import GalleryPicker
import CoreUI

final class ResultViewController: UIViewController {

    override var prefersStatusBarHidden: Bool { return true }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var playerView = PlayerView()
    let content: MediaContentFetchResult
    
    init(content: MediaContentFetchResult) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
  
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(playerView)
        
        
        switch content {
        case .asset(let asset):
           let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            playerView.player = player
            player.play()
            imageView.isHidden = true
            break
        case .image(let image):
            imageView.image = image
            playerView.isHidden = true
        case .error:
            break
        }
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        playerView.frame = view.bounds

    }
}
