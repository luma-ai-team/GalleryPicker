//
//  Copyright © 2020 Rosberry. All rights reserved.
//

protocol Weak: AnyObject {
    associatedtype T: AnyObject
    var object: T? { get }
}

final class WeakRef<T: AnyObject>: Weak {
    private(set) public weak var object: T?
    init(object: T) {
        self.object = object
    }
}
