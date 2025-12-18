//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    // Different keys
    enum UserDefaultKeys {
        case savedSlices
        
        var title: String {
            switch self {
            case .savedSlices:
                return "savedSlices"
            }
        }
    }
    
    private let userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults.standard
    }
    
    func saveSlices(slices: [Slice]) {
        let sliceData = slices.map( { SliceData(slice: $0) } )
        if let encoded = try? JSONEncoder().encode(sliceData) {
            userDefaults.set(encoded, forKey: UserDefaultKeys.savedSlices.title)
        }
    }
    
    func getSlices() -> [Slice] {
        guard let data = userDefaults.data(forKey: UserDefaultKeys.savedSlices.title) else { return [] }
        if let sliceData = try? JSONDecoder().decode([SliceData].self, from: data) {
            return sliceData.map { Slice(data: $0) }
        }
        return []
    }
    
    func removeSlices() {
        userDefaults.removeObject(forKey: UserDefaultKeys.savedSlices.title)
    }
}
