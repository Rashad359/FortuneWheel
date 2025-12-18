//

import Foundation
import UIKit
import Combine

final class SettingsBuilder {
    func build(in storage: inout Set<AnyCancellable>, receive: @escaping(Bool) -> Void) -> UIViewController {
        let viewModel = SettingsViewModel()
        let settingsVC = SettingsViewController(viewModel: viewModel)
        settingsVC.$updateWheel.sink(receiveValue: receive).store(in: &storage)
        return settingsVC
    }
}
