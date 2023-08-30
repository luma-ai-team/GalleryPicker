//
//  Copyright © 2021 SocialKit. All rights reserved.
//
import UIKit
import GalleryPicker

final class PixabayPresenter {
    weak var view: PixabayViewInput?
    weak var output: PixabayModuleOutput?

    var state: PixabayState
    let api = PixabayAPI()
    
    init(state: PixabayState) {
        self.state = state
    }
    
    func fetchContent() {
        self.state.fetchState = .loading
        update(animated: false)
        Task {
            do {
                let medias = try await api.fetchMedia(type: state.mediaType, query: state.text)
                self.state.medias = medias
                self.state.fetchState = medias.count > 0 ? .showingResult : .showingError(text: "No Results Found.")
                await MainActor.run {
                    update(animated: false)
                }
                
            } catch {
                self.state.fetchState = .showingError(text: "Error Occured. Please Try Again")
                print("Error fetching data: \(error)")
                // Consider adding user-facing error handling, e.g., displaying an alert.
            }
        }
    }
}


// MARK: - CanvasViewOutput

extension PixabayPresenter: PixabayViewOutput {
    
    func wantsToSelect(pixabayMedia: PixabayMedia, thumbnail: UIImage?) {
        output?.pixabayModule(self, wantsToSelectPixabayMedia: pixabayMedia, thumbnail: thumbnail)
    }
        
    func contentTypeUpdated(type: PixabaySearchType) {
        state.mediaType = type
        fetchContent()
    }
    
    
    func textUpdated(text: String) {
        state.text = text
    }
    
    func searchTapped() {
        fetchContent()
    }
    
    
    func viewDidLoad() {
        fetchContent()
        update(force: true, animated: false)
    }
    
}

// MARK: - CanvasModuleInput

extension PixabayPresenter: PixabayModuleInput {
    
    func update(force: Bool = false, animated: Bool) {
        let viewModel = PixabayViewModel(state: state)
        view?.update(with: viewModel, force: force, animated: animated)
    }
}
