//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import CoreUI

public protocol AssetFetchViewInput: AnyObject {
    func dismiss()
    func update(with viewModel: AssetFetchViewModel, force: Bool, animated: Bool)
}

public protocol AssetFetchViewOutput: AnyObject {
    func viewDidLoad()
    func dismissTapped()
    func viewTapGesture()
}

public final class AssetFetchViewController: SheetViewController {

    private var viewModel: AssetFetchViewModel
    public var output: AssetFetchViewOutput?
    
    let importingFromICloudView: ImportingFromICloudView = UIView.fromNib(bundle: .module)
    let errorImportingView: ErrorImportingView = UIView.fromNib(bundle: .module)
    private weak var activeContext: UIViewController?

    public init(viewModel: AssetFetchViewModel) {
        self.viewModel = viewModel
        let colorScheme = viewModel.colorScheme
        
        let contentableViewAppearance = ContentableViewAppearance(
            backgroundColor: colorScheme.foreground,
            closeTintColor: colorScheme.subtitle,
            closeImage: nil,
            viewBackgroundStyle: .color(UIColor.black.withAlphaComponent(0.7)))
        
        super.init(initWith: importingFromICloudView, appearance: contentableViewAppearance)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0

        let colorScheme = viewModel.colorScheme
        // apply appearance
        
        // Progress View
        importingFromICloudView.title.textColor = colorScheme.title
        importingFromICloudView.indicator.color = colorScheme.title
        importingFromICloudView.indicator.tintColor = colorScheme.title
        importingFromICloudView.progressView.progressGradient = colorScheme.gradient
        importingFromICloudView.progressView.backgroundColor = colorScheme.notActive
        
        // Error
        errorImportingView.title.textColor = colorScheme.title
        errorImportingView.subtitle.textColor = colorScheme.subtitle
        
        output?.viewDidLoad()
    }


    // MARK: - Actions
    public override func closeTapped() {
        output?.dismissTapped()
    }
    
    public override func viewDimmedTapped() {
        output?.viewTapGesture()
    }
    
}

// MARK: - AssetFetchViewInput

extension AssetFetchViewController: AssetFetchViewInput {

    func inject(errorView: ErrorImportingView) {
        contentView = errorView
    }
    

    public func dismiss() {
        activeContext = nil
        dismiss(animated: true, completion: nil)
    }

    public func update(with viewModel: AssetFetchViewModel, force: Bool, animated: Bool) {
        loadViewIfNeeded()

        self.viewModel = viewModel
        switch viewModel.fetchState {
        case .failed:
            view.alpha = 1
            setContentView(errorImportingView, animated: animated)
        case .fetching(let text, let progress):
            view.alpha = 1
            if contentView !== importingFromICloudView {
                setContentView(importingFromICloudView, animated: animated)
            }
            importingFromICloudView.title.text = text
            importingFromICloudView.progressView.setProgress(progress: CGFloat(progress),
                                                             animation: .animated(duration: 0.15))
        case .local:
            view.alpha = 0
        }
    
        if activeContext !== viewModel.context, viewModel.fetchState.isRemoteAsset {
            viewModel.context?.present(self, animated: true, completion: nil)
            activeContext = viewModel.context
        }
    }
}
