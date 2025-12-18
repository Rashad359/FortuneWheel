//

import Foundation
import UIKit
import SnapKit

protocol SliceCellDelegate: AnyObject {
    func didChangeRate(value: Int, in cell: SliceCell)
}

final class SliceCell: UITableViewCell {
    
    weak var delegate: SliceCellDelegate? = nil
    
    private let categoryName: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.textColor = .black
        
        return label
    }()
    
    private lazy var categoryOdds: UITextField = {
        let textField = UITextField()
        textField.addTarget(self, action: #selector(didChangeOdds), for: .editingChanged)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: "odds...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.textAlignment = .right
        
        return textField
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapDone))
        
        toolbar.items = [flexibleSpace, doneButton]
        
        return toolbar
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
        categoryOdds.inputAccessoryView = toolbar
        
        selectionStyle = .none
        backgroundColor = .white
        
        contentView.addSubview(mainStackView)
        
        [categoryName, categoryOdds].forEach(mainStackView.addArrangedSubview)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    @objc private func didChangeOdds() {
        guard let text = categoryOdds.text,
              let value = Int(text) else { return }
        delegate?.didChangeRate(value: value, in: self)
    }
    
    @objc private func didTapDone() {
        endEditing(true)
    }
}

extension SliceCell {
    struct Item {
        let categoryName: String
        let categoryOdds: Int
    }
    
    func configure(_ item: Item) {
        categoryName.text = item.categoryName
        categoryOdds.text = String(item.categoryOdds)
    }
}

extension SliceCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRanges ranges: [NSValue], replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didChangeOdds()
        categoryOdds.resignFirstResponder()
        return true
    }
}
