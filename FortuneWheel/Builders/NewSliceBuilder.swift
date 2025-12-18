//

import Foundation
import UIKit
import Combine

final class NewSliceBuilder {
    func build(in storage: inout Set<AnyCancellable>, completion: @escaping((String, UIColor)) -> Void) -> UIViewController {
        let viewModel = NewSliceViewModel()
        let newSliceVC = NewSliceViewController(viewModel: viewModel)
        newSliceVC.slicePublisher.sink(receiveValue: completion).store(in: &storage)
        return newSliceVC
    }
}
