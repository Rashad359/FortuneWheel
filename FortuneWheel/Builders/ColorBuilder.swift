//

import Foundation
import UIKit
import Combine

final class ColorBuilder {
    func build(storage: inout Set<AnyCancellable>, completion: @escaping(Bool) -> Void) -> UIViewController {
        let viewModel = ColorViewModel()
        let colorVC = ColorViewController(viewModel: viewModel)
        colorVC.$updateWheel.sink(receiveValue: completion).store(in: &storage)
        return colorVC
    }
}
