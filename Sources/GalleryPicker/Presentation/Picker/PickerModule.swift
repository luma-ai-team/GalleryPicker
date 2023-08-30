//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol PickerModuleInput: AnyObject {
    var state: PickerState { get }

    func activate()

    func update(with album: Album)
    func update(force: Bool, animated: Bool)
}

public protocol PickerModuleOutput: AnyObject {
    func pickerModuleDidFetchContent(_ moduleInput: PickerModuleInput)
    func pickerModule(_ moduleInput: PickerModuleInput, didSelect mediaItem: MediaItem)
    func pickerModule(_ moduleInput: PickerModuleInput, didDeselect mediaItem: MediaItem)
    func pickerModuleDidRequestActivate(_ moduleInput: PickerModuleInput)
    func pickerModuleWantsToOpenFullAccessSettings(_ moduleInput: PickerModuleInput)
    func pickerModuleDidRequestSystemPicker(_ moduleInput: PickerModuleInput)
}

public final class PickerModule {
    public var input: PickerModuleInput {
        return presenter
    }

    public var output: PickerModuleOutput? {
        get {
            return presenter.output
        }
        set {
            presenter.output = newValue
        }
    }
    
    public let viewController: PickerViewController
    private let presenter: PickerPresenter

    public init(state: PickerState) {
        let presenter = PickerPresenter(state: state)
        let viewModel = PickerViewModel(state: state)
        let viewController = PickerViewController(viewModel: viewModel, output: presenter)
        presenter.view = viewController
        self.viewController = viewController
        self.presenter = presenter
    }
}
