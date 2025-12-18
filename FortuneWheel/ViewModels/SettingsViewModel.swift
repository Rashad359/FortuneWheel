//

import Foundation
import UIKit

final class SettingsViewModel {
    private let userDefaults = UserDefaultsManager.shared
    
    private lazy var slices = userDefaults.getSlices()
    
    func saveLocalSlices(slices: [Slice]) {
        self.slices = slices
    }
    
    func getLocalSlices() -> [Slice] {
        return slices
    }
    
    func saveSlices(slices: [Slice]) {
        userDefaults.saveSlices(slices: slices)
    }
    
    func getSlices() -> [Slice] {
        return userDefaults.getSlices()
    }
    
    func changeSliceRate(value: Int, in cell: SliceCell, for tableView: UITableView) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        var alteredSlices = self.getLocalSlices()
        alteredSlices[indexPath.row].dropRate = value
        self.saveLocalSlices(slices: alteredSlices)
        var newTotalSum = 0
        self.getLocalSlices().forEach( { newTotalSum += $0.dropRate } )
        
        // Delete when not needed
        if newTotalSum < 100 || newTotalSum > 100 {
            // Don't save it
            print("Don't save changes")
        } else {
            // The odds are right
            print("Slice odds are right")
        }
    }
    
    func applyChanges(completion: @escaping(Bool) -> Void) {
        var totalSum: Int = 0
        self.getLocalSlices().forEach( { totalSum += $0.dropRate } )
        
        if totalSum > 100 || totalSum < 100 {
            
            completion(false)
            
        } else {
            
            completion(true)
            
        }
    }
}
