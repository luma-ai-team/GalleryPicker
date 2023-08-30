//
//  Copyright © 2020 Craftiz. All rights reserved.
//

final class AlbumsPresenter {

    typealias Dependencies = Any

    weak var view: AlbumsViewInput?
    weak var output: AlbumsModuleOutput?

    var state: AlbumsState

    init(state: AlbumsState) {
        self.state = state
    }
}

// MARK: - AlbumsViewOutput

extension AlbumsPresenter: AlbumsViewOutput {
    func didSelect(album: Album) {
        output?.albumsModule(didSelect: album)
    }
    
    func viewDidLoad() {
        update(force: true, animated: false)
        fetchContent()
    }
    
    func viewWillDisappear() {
        output?.albumsModuleWillDismiss(self)
    }

    private func fetchContent() {
        let filter = state.configuration.filter.ignoringAuxiliaryPredicate()
        GalleryAssetService.shared.fetchAlbums(filter: filter) { [weak self] (albums: [Album]) in
            self?.state.albums = albums
            self?.update(force: true, animated: false)
        }

        GalleryAssetService.shared.observe(state.observer)
    }
}

// MARK: - AlbumsModuleInput

extension AlbumsPresenter: AlbumsModuleInput {

    func update(force: Bool = false, animated: Bool) {
        let viewModel = AlbumsViewModel(state: state)
        state.observer.handler = { [weak self] _ in
            self?.fetchContent()
        }

        view?.update(with: viewModel, force: force, animated: animated)
    }
}
