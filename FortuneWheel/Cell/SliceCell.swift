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
        textField.addTarget(self, action: #selector(didChangeOdds), for: .editingDidEnd)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: "odds...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        return textField
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
