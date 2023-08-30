//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import AVFoundation

public protocol VideoAssetFetchModuleOutput: AnyObject {
    func assetFetchModuleCancelledOperation(_ moduleInput: AssetFetchModuleInput)
    func assetFetchModuleFinishedOperation(_ moduleInput: AssetFetchModuleInput, asset: AVAsset, for item: MediaItem)
}

public final class VideoAssetFetchModule {

    public var input: AssetFetchModuleInput {
        return presenter
    }

    public var output: VideoAssetFetchModuleOutput? {
        get {
            return presenter.videoFetchOutput
        }
        set {
            presenter.videoFetchOutput = newValue
        }
    }

    public let viewController: AssetFetchViewController
    private let presenter: VideoAssetFetchPresenter

    public init(state: AssetFetchState) {
        let presenter = VideoAssetFetchPresenter(state: state, dependencies: [Any]())
        let viewController: AssetFetchViewController = .init(viewModel: AssetFetchViewModel(state: state))
        viewController.output = presenter

        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
    }
}
