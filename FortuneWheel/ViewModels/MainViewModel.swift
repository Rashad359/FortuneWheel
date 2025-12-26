//

import Foundation
import UIKit
import Combine

final class MainViewModel {
    
    // MARK: - Initial variables
    
    private var spinHistory: [Int: Int] = [:]
    private var totalSpins = 0
    
    private let correctionStrength: Double = 100.0
    
    private let router: Router?
    
    private let userDefaults = UserDefaultsManager.shared
    
    private var slices = [Slice]()
    
    init(router: Router?) {
        self.router = router
    }
    
    // MARK: - Getter and Setter for slices
    
    func setSlice(slices: [Slice]) {
        self.slices = slices
    }
    
    func getSlice() -> [Slice] {
        return slices
    }
    
    // MARK: - Navigation
    
    func navigateToNewCategory(in storage: inout Set<AnyCancellable>, completion: @escaping ((String, UIColor)) -> Void) {
        router?.goToNewCategory(in: &storage, completion: completion)
    }
    
    func navigateToSettings(in storage: inout Set<AnyCancellable>, receive: @escaping(Bool) -> Void) {
        router?.goToSettings(in: &storage, receive: receive)
    }
    
    func navigateToColors(storage: inout Set<AnyCancellable>, completion: @escaping(Bool) -> Void) {
        router?.goToColors(storage: &storage, completion: completion)
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
    
    // MARK: - Different odds calulations
    
    // The odds that will adjust themselves depending on how many times they have been dropped
    func adaptiveRandomOdds() -> Int {
        let slices = getSlices()
        
        var dynamicWeights: [Double] = []
        var totalDynamicWeight: Double = 0
        
        for (index, slice) in slices.enumerated() {
            let actualWinCount = spinHistory[index, default: 0]
            let expectedWinCount = Double(totalSpins) * (Double(slice.dropRate) / 100)
            
            let diff = Double(actualWinCount) - expectedWinCount
            
            var adjustedRate = Double(slice.dropRate) - (diff * correctionStrength)
            
            if slice.dropRate > 0 {
                adjustedRate = max(1.0, adjustedRate)
            } else {
                adjustedRate = 0
            }
            
            dynamicWeights.append(adjustedRate)
            totalDynamicWeight += adjustedRate
        }
        
        let randomValue = Double.random(in: 0..<totalDynamicWeight)
        var cumulative = 0.0
        
        var winnerIndex = 0
        
        for (index, weight) in dynamicWeights.enumerated() {
            cumulative += weight
            if randomValue <= cumulative {
                winnerIndex = index
                break
            }
        }
        
        print("Dynamic weights array: \(dynamicWeights)")
        print("Total dynamic weight: \(totalDynamicWeight)")
        
        recordWin(index: winnerIndex)
        
        return winnerIndex
    }
    
    private func recordWin(index: Int) {
        spinHistory[index, default: 0] += 1
        totalSpins += 1
        
        print("Spin history: \(spinHistory)")
        
        if totalSpins >= 100 {
            totalSpins /= 2
            for (key, val) in spinHistory {
                spinHistory[key] = val / 2
            }
        }
    }
    
    func resetHistory() {
        spinHistory.removeAll()
        totalSpins = 0
    }
    
    // Use this for giving totally random odds that depends on nothing. The next spin is independent of the last
    private func totallyRandomOdds() -> Int {
        
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

    func calculateOdds() -> Int {
        return adaptiveRandomOdds()
    }
}
