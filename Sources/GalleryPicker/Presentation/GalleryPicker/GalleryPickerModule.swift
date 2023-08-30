//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos

public protocol GalleryPickerModuleInput: AnyObject {
    var state: GalleryPickerState { get }

    var pickerModule: PickerModule { get }
    var albumsModule: AlbumsModule { get }

    func activate()
    func update(force: Bool, animated: Bool)
    func dismiss()

    func addLeftBarButtonAction(_ action: (() -> Void)?)
    func addRightBarButtonAction(_ action: (() -> Void)?)

    func retainOutput()
    func releaseOutput()

    func finalize()
}

public protocol GalleryPickerModuleOutput: AnyObject {
    func galleryPickerModuleDidUpdatePermissions(_ moduleInput: GalleryPickerModuleInput, status: PHAuthorizationStatus)
    func galleryPickerModule(_ moduleInput: GalleryPickerModuleInput, didSelect mediaItem: MediaItem)
    func galleryPickerModule(_ moduleInput: GalleryPickerModuleInput, didDeselect mediaItem: MediaItem)
    func galleryPickerModuleDidDismiss(_ moduleInput: GalleryPickerModuleInput)
    func galleryPickerModuleCanSelectMoreMedia(_ moduleInput: GalleryPickerModuleInput) -> Bool
}

public final class GalleryPickerModule {

    public var input: GalleryPickerModuleInput {
        return presenter
    }

    public var output: GalleryPickerModuleOutput? {
        get {
            return presenter.output
        }
        set {
            presenter.output = newValue
        }
    }
    
    public let viewController: GalleryPickerViewController
    public let presenter: GalleryPickerPresenter
    let galleryCoordinator: GalleryCoordinator

    public init(state: GalleryPickerState) {
        let viewModel = GalleryPickerViewModel(state: state)
        let presenter = GalleryPickerPresenter(state: state)
        let viewController = GalleryPickerViewController(viewModel: viewModel, output: presenter)
        let galleryCoordinator = GalleryCoordinator(rootViewController: viewController, galleryPickerConfiguration: state.galleryPickerConfiguration, albumsModule: presenter.albumsModule, pickerModule: presenter.pickerModule)
        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
        self.galleryCoordinator = galleryCoordinator
        presenter.galleryCoordinator = galleryCoordinator
        galleryCoordinator.galleryPickerPresenter = presenter
        galleryCoordinator.start()
    }
}
