//
//  Copyright © 2020 Rosberry. All rights reserved.
//

extension Array where Element: Weak {

    var strongReferences: [Element.T] {
        return compactMap({ (element: Element) -> Element.T? in
            return element.object
        })
    }

    mutating func append(weak: Element.T) {
        guard let object: Element = WeakRef(object: weak) as? Element else {
            return
        }

        append(object)
    }

    mutating func remove(_ weak: Element.T) {
        for (index, element) in enumerated() where element.object === weak {
            remove(at: index)
            break
        }
    }

    mutating func compact() -> Array {
        self = filter({ (element: Element) -> Bool in
            return element.object != nil
        })

        return self
    }
}
