//

import Foundation
import UIKit
import Combine

class Router {
    weak var view: UIViewController?
    
    func goToNewCategory(in storage: inout Set<AnyCancellable>, completion: @escaping((String, UIColor)) -> Void) {
        let newSliceVC = NewSliceBuilder().build(in: &storage, completion: completion)
        view?.present(newSliceVC, animated: true)
    }
    
    func goToSettings(in storage: inout Set<AnyCancellable>, receive: @escaping(Bool) -> Void) {
        let settingsVC = SettingsBuilder().build(in: &storage, receive: receive)
        view?.present(settingsVC, animated: true)
    }
}
