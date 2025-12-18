//

import Foundation
import UIKit

class BaseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .link
        tintColor = .white
        layer.cornerRadius = 12
        setTitleColor(.white, for: .normal)
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
