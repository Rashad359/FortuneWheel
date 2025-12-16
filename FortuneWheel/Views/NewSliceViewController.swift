//

import Foundation
import UIKit
import SnapKit

// Change to combine later

protocol NewSliceViewDelegate: AnyObject {
    func didAddSlice(with category: String, color: UIColor)
}

final class NewSliceViewController: UIViewController, Keyboardable {
    
    var targetConstraint: SnapKit.Constraint?
    
    weak var delegate: NewSliceViewDelegate? = nil
    
    private let addLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Category"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        return button
    }()
    
    private let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private lazy var sliceNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textField.textColor = .black
        textField.tintColor = .black
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        // Placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: "Category...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        return textField
    }()
    
//    private let sliceColorTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Color..."
//        
//        return textField
//    }()
    
    private let sliceNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        
        return stackView
    }()
    
    private lazy var addSliceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add slice", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapAddSlice), for: .touchUpInside)
        
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter the category name"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.isHidden = true
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startKeyboardObserve(with: -10)
    }
    
    private func setupUI() {
        
        // Dismissing keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .white
        
        [topStackView, sliceNameStackView, addSliceButton, warningLabel].forEach(view.addSubview)
        
        [addLabel, backButton].forEach(topStackView.addArrangedSubview)
        
        [sliceNameTextField].forEach(sliceNameStackView.addArrangedSubview)
        
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        sliceNameStackView.snp.makeConstraints { make in
            make.top.equalTo(addLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        addSliceButton.snp.makeConstraints { make in
            targetConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10).constraint
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(48)
        }
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(sliceNameStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
    
    @objc private func didTapAddSlice() {
        guard let sliceText = sliceNameTextField.text, !sliceText.isEmpty else {
            warningLabel.isHidden = false
            return
        }
        warningLabel.isHidden = true
        self.delegate?.didAddSlice(with: sliceText, color: .random())
        self.dismiss(animated: true)
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true)
    }
}
