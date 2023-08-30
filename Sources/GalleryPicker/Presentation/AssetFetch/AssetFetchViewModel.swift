//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import CoreUI

public final class AssetFetchViewModel {
    let context: UIViewController?
    let colorScheme: ColorScheme
    let fetchState: FetchState
    public init(state: AssetFetchState) {
        context = state.context
        self.fetchState = state.fetchState
        self.colorScheme = state.colorScheme
    }
}
