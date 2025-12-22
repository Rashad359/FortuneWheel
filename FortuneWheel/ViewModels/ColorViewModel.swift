//

import Foundation
import UIKit

final class ColorViewModel {
    private let userDefaults = UserDefaultsManager.shared
    
    func getSlices() -> [Slice] {
        userDefaults.getSlices()
    }
    
    func saveSlices(slices: [Slice]) {
        userDefaults.saveSlices(slices: slices)
    }
}
