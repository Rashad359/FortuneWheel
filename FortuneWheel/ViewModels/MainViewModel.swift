//

import Foundation
import UIKit

final class MainViewModel {
    private let router: Router
    
    private let userDefaults = UserDefaultsManager.shared
    
    private var slices = [Slice]()
    
    init(router: Router) {
        self.router = router
    }
    
    // MARK: - Getter and Setter for slice
    func setSlice(slices: [Slice]) {
        self.slices = slices
    }
    
    func getSlice() -> [Slice] {
        return slices
    }
    
    // MARK: - Navigation
    
    func navigateToNewCategory(delegate: NewSliceViewDelegate) {
        router.goToNewCategory(delegate: delegate)
    }
    
    func navigateToSettings(delegate: SettingsViewDelegate) {
        router.goToSettings(delegate: delegate)
    }
    
    // MARK: - Saving and getting slices from userDefaults
    func saveSlices(slices: [Slice]) {
        userDefaults.saveSlices(slices: slices)
    }
    
    func getSlices() -> [Slice] {
        return userDefaults.getSlices()
    }
    
    func addSlice(text: String, color: UIColor, dropRate: Int) {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        var slice = Slice.init(label: label)
        slice.dropRate = dropRate
        slice.color = color
        
        // Append new slice
        var slices = self.getSlices()
        slices.append(slice)
        self.saveSlices(slices: slices)
    }
    
    func appendSlice(category: String, color: UIColor) {
        let totalRate = 100
        var totalSlicesRate: Int = 0
        self.getSlices().forEach( { totalSlicesRate += $0.dropRate} )
        let remainingRate = totalRate - totalSlicesRate
        self.addSlice(text: category, color: color, dropRate: remainingRate)
    }
    
    func calculateOdds() -> Int {
        let randomValue = Int.random(in: 1...100)
        
        var cumulativeRate = 0
        
        for (index, slice) in self.getSlices().enumerated() {
            cumulativeRate += slice.dropRate
            
            if randomValue <= cumulativeRate {
                return index
            }
        }
        
        print("Falling back")
        return 0
    }
}
