//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import AVFoundation

public protocol AssetFetchModuleInput: GalleryPickerModuleOutput {

    var state: AssetFetchState { get }
    func update(force: Bool, animated: Bool)
    func dismiss()
}

public protocol AssetFetchModuleOutput: VideoAssetFetchModuleOutput {
    func assetFetchModuleFinishedOperation(_ moduleInput: AssetFetchModuleInput, image: UIImage, for item: MediaItem)
    func assetFetchModuleDidUpdatePermissions(_ moduleInput: AssetFetchModuleInput)
}

public final class AssetFetchModule {

    public var input: AssetFetchModuleInput {
        return presenter
    }

    public var output: AssetFetchModuleOutput? {
        get {
            return presenter.output
        }
        set {
            presenter.output = newValue
        }
    }

    public let viewController: AssetFetchViewController
    private let presenter: AssetFetchPresenter

    public init(state: AssetFetchState) {
        let presenter = AssetFetchPresenter(state: state, dependencies: [Any]())
        let viewController: AssetFetchViewController = .init(viewModel: AssetFetchViewModel(state: state))
        viewController.output = presenter

        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
    }
}
