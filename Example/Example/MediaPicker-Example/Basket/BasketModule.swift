//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation
import GalleryPicker

protocol BasketModuleInput: AnyObject {
    var state: BasketState { get }
    func update(force: Bool, animated: Bool)
    func triggerMaxSelectionAnimation()
    func insertMediaItem(mediaItem: MediaItem)
}

protocol BasketModuleOutput: AnyObject {
    func basketModule(_ moduleInput: BasketModuleInput, wantsToDeleteMediaItem mediaItem: MediaItem?)
    func basketModuleDoneTapped(_ moduleInput: BasketModuleInput)
}

final class BasketModule {

    var input: BasketModuleInput {
        presenter
    }
    var output: BasketModuleOutput? {
        get {
            presenter.output
        }
        set {
            presenter.output = newValue
        }
    }
    let viewController: BasketViewController
    private let presenter: BasketPresenter

    init(state: BasketState) {
        let presenter = BasketPresenter(state: state)
        let viewModel = BasketViewModel(state: state)
        let viewController = BasketViewController(viewModel: viewModel, output: presenter)
        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
    }
}
