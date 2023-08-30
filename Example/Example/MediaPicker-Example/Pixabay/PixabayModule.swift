//
//  Copyright © 2021 SocialKit. All rights reserved.
//
import UIKit
import GalleryPicker

protocol PixabayModuleInput: AnyObject {
    var state: PixabayState { get }
    func update(force: Bool, animated: Bool)
}

protocol PixabayModuleOutput: AnyObject {
    func pixabayModule(_ moduleInput: PixabayModuleInput, wantsToSelectPixabayMedia pixabayMedia: PixabayMedia, thumbnail: UIImage?)
}

final class PixabayModule {

    var input: PixabayModuleInput {
        return presenter
    }
    var output: PixabayModuleOutput? {
        get {
            return presenter.output
        }
        set {
            presenter.output = newValue
        }
    }
    let viewController: PixabayViewController
    private let presenter: PixabayPresenter

    init(state: PixabayState) {
        let presenter = PixabayPresenter(state: state)
        let viewModel = PixabayViewModel(state: state)
        let viewController = PixabayViewController(viewModel: viewModel, output: presenter)
        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
    }
}
