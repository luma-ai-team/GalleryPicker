//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import PhotosUI
import PermissionKit

public final class GalleryPickerPresenter {

    weak var view: GalleryPickerViewInput?
    weak var output: GalleryPickerModuleOutput?
    private var retainedOutput: GalleryPickerModuleOutput?
    
    public let albumsModule: AlbumsModule
    public let pickerModule: PickerModule
    
    var galleryCoordinator: GalleryCoordinator?

    public var state: GalleryPickerState

    init(state: GalleryPickerState) {
        let albumsState = AlbumsState(configuration: state.galleryPickerConfiguration.albumsConfiguration)
        let albumsModule = AlbumsModule(state: albumsState)
        self.albumsModule = albumsModule
        
        let pickerState = PickerState(pickerConfiguration: state.galleryPickerConfiguration.pickerConfiguration)
        let pickerModule = PickerModule(state: pickerState)
        self.pickerModule = pickerModule
        self.state = state
        
        pickerModule.output = self
        albumsModule.output = self
    }
}

// MARK: - GalleryPickerViewOutput

extension GalleryPickerPresenter: GalleryPickerViewOutput {
   
    func albumsButtonTapped() {
        state.isAlbumsModuleVisible = true
        update(animated: true)
        
        galleryCoordinator?.presentAlbumsViewController()
    }

    func viewDidLoad() {
        update(force: true, animated: false)
    }
}

// MARK: - GalleryPickerModuleInput

extension GalleryPickerPresenter: GalleryPickerModuleInput {

    public func addLeftBarButtonAction(_ action: (() -> Void)?) {
        view?.addLeftBarButtonAction(action)
    }

    public func addRightBarButtonAction(_ action: (() -> Void)?) {
        view?.addRightBarButtonAction(action)
    }
    
    public func activate() {
        let accessLevel = PHAccessLevel.readWrite
        let shouldReportPermissionsStatus = PhotoLibraryPermission.currentStatus(for: accessLevel) == .notDetermined
        
        
        PhotoLibraryPermission.requestPermission(for: accessLevel) {[weak self] (permissionStatus) in
            guard let self = self else {
                return
            }

            self.state.permissionStatus = permissionStatus
            if permissionStatus == .authorized {
                let filter = self.state.galleryPickerConfiguration.filter
                GalleryAssetService.shared.fetchAlbums(filter: filter.ignoringAuxiliaryPredicate()) { [weak self] (albums: [Album]) in
                    self?.state.album = self?.state.album ?? albums.first
                    self?.pickerModule.input.state.album = self?.state.album
                    self?.pickerModule.input.activate()
                    self?.update(force: false, animated: false)
                }
            }
            else {
                self.pickerModule.input.activate()
            }
            
            self.update(force: true, animated: false)
            self.albumsModule.viewController.loadViewIfNeeded()

            if shouldReportPermissionsStatus {
                self.output?.galleryPickerModuleDidUpdatePermissions(self,
                                                                     status: PhotoLibraryPermission.currentStatus(for: accessLevel)
                )
            }
        }

      
    }

    public func update(force: Bool = false, animated: Bool) {
        let viewModel = GalleryPickerViewModel(state: state)
        view?.update(with: viewModel, force: force, animated: animated)
    }

    public func dismiss() {
        view?.dismiss()
    }

    public func retainOutput() {
        retainedOutput = output
    }

    public func releaseOutput() {
        retainedOutput = nil
    }

    public func finalize() {
        state.hasContent = true
        update(animated: true)

        view?.dismiss()
    }
}

extension GalleryPickerPresenter: PickerModuleOutput {


    public func pickerModuleDidFetchContent(_ moduleInput: PickerModuleInput) {
        guard state.hasContent == false else {
            return
        }
        
        state.hasContent = true
        update(animated: true)
    }
    
    public func pickerModule(_ moduleInput: PickerModuleInput, didSelect mediaItem: MediaItem) {
        output?.galleryPickerModule(self, didSelect: mediaItem)
    }

    public func pickerModule(_ moduleInput: PickerModuleInput, didDeselect mediaItem: MediaItem) {
        output?.galleryPickerModule(self, didDeselect: mediaItem)
    }

    public func pickerModuleDidRequestActivate(_ moduleInput: PickerModuleInput) {
        activate()
    }

    public func pickerModuleDidRequestSystemPicker(_ moduleInput: PickerModuleInput) {
        galleryCoordinator?.pickerModuleDidRequestSystemPicker(self)
    }
}

extension GalleryPickerPresenter: AlbumsModuleOutput {
    public func albumsModule(didSelect album: Album) {
        state.album = album
        update(force: false, animated: false)

        pickerModule.input.update(with: album)
        galleryCoordinator?.dismissAlbumsViewController()
    }
    
    public func albumsModuleWillDismiss(_ sender: AlbumsModuleInput) {
        state.isAlbumsModuleVisible = false
        update(animated: true)
    }

    func dismissEventTriggered() {
        output?.galleryPickerModuleDidDismiss(self)
    }

    func fallbackPickerCompletionEvenTriggered(items: [MediaItem]) {
        for item in items {
            output?.galleryPickerModule(self, didSelect: item)
        }
    }
}

