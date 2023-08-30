//
//  Copyright © 2020 Craftiz. All rights reserved.
//

public protocol AlbumsModuleInput: AnyObject {

    var state: AlbumsState { get }
    func update(force: Bool, animated: Bool)
}

public protocol AlbumsModuleOutput: AnyObject {
    func albumsModule(didSelect album: Album)
    func albumsModuleWillDismiss(_ sender: AlbumsModuleInput)
}

public final class AlbumsModule {

    var input: AlbumsModuleInput {
        return presenter
    }
    public var output: AlbumsModuleOutput? {
        get {
            return presenter.output
        }
        set {
            presenter.output = newValue
        }
    }
    public let viewController: AlbumsViewController
    private let presenter: AlbumsPresenter

    public init(state: AlbumsState) {
        let presenter = AlbumsPresenter(state: state)
        let viewModel = AlbumsViewModel(state: state)
        let viewController = AlbumsViewController(viewModel: viewModel, output: presenter)
        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
    }
}
