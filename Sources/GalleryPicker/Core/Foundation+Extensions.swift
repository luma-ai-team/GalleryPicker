//
//  Created by Roi Mulia on 27/07/2020.
//

import Foundation

public extension TimeInterval {
     func toReadableMinutesAndSecondsString() -> String {
        let minutes = Int(floor(self / 60))
        let seconds = Int(Darwin.round(self.truncatingRemainder(dividingBy: 60)))
        return String(format: "%d:%02d", minutes, seconds)
    }
}
