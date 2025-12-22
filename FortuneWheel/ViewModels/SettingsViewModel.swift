//

import Foundation
import UIKit
import Combine

final class SettingsViewModel {
    
    @Published private(set) var deleateSlice: Bool = false
    
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
    
    func deleteSlice(at indexPath: IndexPath) {
        var deletedSlices: [Slice] = self.getSlices()
        
        deletedSlices.remove(at: indexPath.row)
        
        var finalSlices: [Slice] = []
        
        var totalSum = 0
        
        var toAdd = 0
        
        var distributedTotal = 0
        
        for slice in deletedSlices {
            totalSum += slice.dropRate
        }
        
        if totalSum < 100 || totalSum > 100 {
            // The odds are wrong. Distribute them to add up to 100
            
            guard deletedSlices.count != 0 else {
                self.deleateSlice = true
                return
            }
            
            toAdd = (100 - totalSum) / deletedSlices.count
            
            for slice in deletedSlices {
                var slice = slice
                slice.dropRate += toAdd
                distributedTotal += slice.dropRate
                finalSlices.append(slice)
            }
            
            let leftOver = 100 - distributedTotal
            
            if let fixIndex = finalSlices.indices.first(where: { $0 != indexPath.row }) {
                finalSlices[fixIndex].dropRate += leftOver
            }
            
            self.saveSlices(slices: finalSlices)
            
        } else {
            // The odds are right
            self.saveSlices(slices: deletedSlices)
        }
    }
    
    func equateOdds() {
        var finalSlices: [Slice] = []
        
        let totalSum = 100
        
        var distributedSum = 0
        
        for slice in slices {
            var slice = slice
            slice.dropRate = totalSum / slices.count
            finalSlices.append(slice)
            distributedSum += slice.dropRate
        }
        
        let dust = totalSum - distributedSum
        
        finalSlices[0].dropRate += dust
        
        self.saveLocalSlices(slices: finalSlices)
        self.saveSlices(slices: finalSlices)
    }
}
