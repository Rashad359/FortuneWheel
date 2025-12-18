//

import Foundation
import UIKit

final class SettingsBuilder {
    func build(with delegate: SettingsViewDelegate) -> UIViewController {
        let viewModel = SettingsViewModel()
        let settingsVC = SettingsViewController(viewModel: viewModel)
        settingsVC.delegate = delegate
        return settingsVC
    }
}
