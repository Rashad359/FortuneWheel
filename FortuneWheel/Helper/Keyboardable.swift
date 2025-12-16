//

import Foundation
import UIKit
import SnapKit

protocol Keyboardable: AnyObject {
    var targetConstraint: Constraint? { get set }
    
    func startKeyboardObserve(with offset: Int)
}

extension Keyboardable where Self: UIViewController {
    
    private func getHeight(userInfo: [AnyHashable: Any]?) -> CGFloat {
        if let keyboardRect = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            return keyboardRect.height
        }
        return .zero
    }
    
    func startKeyboardObserve(with offset: Int) {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil) {[weak self] notification in
                let height = self?.getHeight(userInfo: notification.userInfo) ?? .zero
                self?.targetConstraint?.update(offset: (-height) + 15)
                self?.view.layoutIfNeeded()
            }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil) {[weak self] notification in
                self?.targetConstraint?.update(offset: offset)
                self?.view.layoutIfNeeded()
            }
        
    }
}
