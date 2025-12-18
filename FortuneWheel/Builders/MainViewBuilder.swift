//

import Foundation
import UIKit

final class MainViewBuilder {
    
    private let router = Router()
    
    func build() -> UIViewController {
        let viewModel = MainViewModel(router: router)
        let vc = MainViewController(viewModel: viewModel)
        router.view = vc
        return vc
    }
}
