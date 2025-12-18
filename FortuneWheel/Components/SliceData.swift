//

import Foundation
import UIKit

struct SliceData: Codable {
    let text: String
    let dropRate: Int
    let colorData: Data
    
    // Helper to convert the stored data back to UIColor
    var uiColor: UIColor {
        return (try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)) ?? .clear
    }
    
    init(slice: Slice) {
        self.text = slice.label.text ?? ""
        self.dropRate = slice.dropRate
        // Convert UIColor to data for saving
        self.colorData = (try? NSKeyedArchiver.archivedData(withRootObject: slice.color, requiringSecureCoding: false)) ?? Data()
    }
    
}
