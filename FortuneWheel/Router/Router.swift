//

import Foundation
import UIKit

class Router {
    weak var view: UIViewController?
    
    func goToNewCategory(delegate: NewSliceViewDelegate) {
        let newSliceVC = NewSliceBuilder().build(with: delegate)
        view?.present(newSliceVC, animated: true)
    }
    
    func goToSettings(delegate: SettingsViewDelegate) {
        let settingsVC = SettingsBuilder().build(with: delegate)
        view?.present(settingsVC, animated: true)
    }
}
