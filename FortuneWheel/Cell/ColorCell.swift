//

import Foundation
import UIKit
import SnapKit

final class ColorCell: UITableViewCell {
    
    var onEditButtonTapped: (() -> ())?
    
    private let categoryName: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.textColor = .black
        label.numberOfLines = .zero
        
        return label
    }()
    
    private let categoryColor: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()
    
    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private lazy var changeColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change color", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(didTapChangeColor), for: .touchUpInside)
        
        return button
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
        
        [categoryStackView, changeColorButton].forEach(mainStackView.addArrangedSubview)
        
        [categoryName, categoryColor].forEach(categoryStackView.addArrangedSubview)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        categoryColor.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
    }
    
    @objc private func didTapChangeColor() {
        onEditButtonTapped?()
    }
}

extension ColorCell {
    struct Item {
        let categoryName: String
        let categoryColor: UIColor
    }
    
    func configure(_ item: Item) {
        categoryName.text = item.categoryName
        categoryColor.backgroundColor = item.categoryColor
    }
}
