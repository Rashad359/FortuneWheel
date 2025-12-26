//

import Foundation
import UIKit

extension Degree {
    func toRadians() -> Radians {
        return (self * .pi) / 180.0
    }
}
