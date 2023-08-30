//
//  Observer.swift
//  
//
//  Created by Anton K on 24.07.2020.
//

import Foundation
import Photos

final class Observer {
    var handler: (PHChange) -> () = { _ in }
}
