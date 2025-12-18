//

import Foundation
import UIKit

final class NewSliceBuilder {
    func build(with delegate: NewSliceViewDelegate?) -> UIViewController {
        let viewModel = NewSliceViewModel()
        let newSliceVC = NewSliceViewController(viewModel: viewModel)
        newSliceVC.delegate = delegate
        return newSliceVC
    }
}
