//

import Foundation
import UIKit
import SnapKit
import Combine

final class NewSliceViewController: BaseViewController, Keyboardable {
    
    var targetConstraint: SnapKit.Constraint?
    
    // MARK: - Private subjects
    private let sliceSubject = PassthroughSubject<(String, UIColor), Never>()
    
    // MARK: - Public read-only Publishers
    var slicePublisher: AnyPublisher<(String, UIColor), Never> {
        sliceSubject.eraseToAnyPublisher()
    }
    
    private let viewModel: NewSliceViewModel
    
    init(viewModel: NewSliceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var addSliceButton: BaseButton = {
        let button = BaseButton(type: .system)
        button.setTitle("Add slice", for: .normal)
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
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose color:"
        label.textColor = .black
        
        return label
    }()
    
    private let selectedColor: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.backgroundColor = .random()
        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()
    
    private let colorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private lazy var selectColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select...", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(didTapSelectColor), for: .touchUpInside)
        
        return button
    }()
    
    private let mainColorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startKeyboardObserve(with: -10)
    }
    
    override func setupUI() {
        super.setupUI()
        sliceNameTextField.becomeFirstResponder()
        
        [topStackView, sliceNameTextField, addSliceButton, warningLabel, mainColorStackView].forEach(view.addSubview)
        
        [addLabel, backButton].forEach(topStackView.addArrangedSubview)
        
        [colorStackView, selectColorButton].forEach(mainColorStackView.addArrangedSubview)
        
        [colorLabel, selectedColor].forEach(colorStackView.addArrangedSubview)
        
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        sliceNameTextField.snp.makeConstraints { make in
            make.top.equalTo(addLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        addSliceButton.snp.makeConstraints { make in
            targetConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10).constraint
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(sliceNameTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        mainColorStackView.snp.makeConstraints { make in
            make.top.equalTo(warningLabel.snp.top).offset(25)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        selectedColor.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        
        // Dismissing keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func presentColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = "Category Color"
        colorPicker.supportsAlpha = false
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        self.present(colorPicker, animated: true)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
    
    @objc private func didTapAddSlice() {
        sliceNameTextField.resignFirstResponder()
        guard let sliceText = sliceNameTextField.text, !sliceText.trimmingCharacters(in: .whitespaces).isEmpty else {
            warningLabel.isHidden = false
            return
        }
        
        warningLabel.isHidden = true
        let sendColor = selectedColor.backgroundColor
        sliceSubject.send((sliceText, sendColor ?? .random()))
        self.dismiss(animated: true)
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTapSelectColor() {
        presentColorPicker()
    }
}

extension NewSliceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapAddSlice()
        return true
    }
}

extension NewSliceViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        selectedColor.backgroundColor = color
    }
}
