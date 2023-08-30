

import UIKit
import Photos
import AVFoundation
import CoreUI
import Combine

public enum PeekPreviewViewControllerSource {
    case mediaItem(MediaItem)
    case image(UIImage)
    case video(AVAsset)

    var ratio: CGFloat {
        switch self {
        case .image(let image):
            return image.size.width / image.size.height
        case .mediaItem(let mediaItem):
            return mediaItem.size.width / mediaItem.size.height
        case .video:
            return 1
        }
    }
}

public class PeekPreviewViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak public var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var cancellable: AnyCancellable?
    
    private let ratio: CGFloat
    private let source: PeekPreviewViewControllerSource

    public init(with source: PeekPreviewViewControllerSource, ratio: CGFloat? = nil) {
        self.source = source
        self.ratio = ratio ?? source.ratio
        super.init(nibName: nil, bundle: Bundle.module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        playerView?.player = nil
        cancellable?.cancel()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        imageView.contentMode = .scaleAspectFill
        preferredContentSize = AVMakeRect(aspectRatio: CGSize(width: ratio, height: 1),
                                          insideRect: UIScreen.main.bounds).size
        view.backgroundColor = .darkGray
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(indicator)
    }

    private func setupContent() {
        switch source {
        case .image(let image):
            imageView.image = image
            playerView.isHidden = true
            indicator.isHidden = true
        case .mediaItem(let mediaItem):
            imageView.image = mediaItem.thumbnail
            fetchAsset(with: mediaItem)
        case .video(let asset):
            imageView.isHidden = true
            playAndLoop(asset)
        }
    }

    private func fetchAsset(with mediaItem: MediaItem) {
        GalleryAssetService.shared.fetchContent(for: [mediaItem]) { [weak self] (_, progress) in
            print(progress)
            self?.indicator.isHidden = false 
        } completion: { [weak self] results in
            self?.handleFetchResults(results)
        }
    }

    private func handleFetchResults(_ results: [MediaContentFetchResult]) {
        guard let result = results.first else { return }

        indicator.isHidden = true
        switch result {
        case .error:
            break
        case .asset(let asset):
            playAndLoop(asset)
        case .image(let image):
            imageView.image = image
            playerView.isHidden = true
        }
    }

    private func playAndLoop(_ avAsset: AVAsset) {
        let player = AVPlayer(playerItem: AVPlayerItem(asset: avAsset))
        setupPlayerLooping(for: player)
        playerView.player = player
        setupPlayerView()
        observePlayerStatus(for: player)
        player.play()
    }

    private func setupPlayerLooping(for player: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }

    private func setupPlayerView() {
        playerView.layer.masksToBounds = true
        playerView.clipsToBounds = true
        playerView.playerLayer?.removeAllAnimations()
        playerView.playerLayer?.speed = 999
    }

    private func observePlayerStatus(for player: AVPlayer) {
        cancellable = player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .playing {
                    self?.indicator.isHidden = true
                }
            }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        GalleryAssetService.shared.cancelContentPendingContentFetches()
    }
}
