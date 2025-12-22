//

import Foundation
import UIKit
import SnapKit
import Combine

final class ColorViewController: BaseViewController {
    
    private let viewModel: ColorViewModel
    
    private var index = 0
    
    @Published private(set) var updateWheel = false
    
    init(viewModel: ColorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Something went wrong in colorViewController")
    }
    
    private let addLabel: UILabel = {
        let label = UILabel()
        label.text = "Change Colors"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ColorCell.self, forCellReuseIdentifier: ColorCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupUI() {
        super.setupUI()
        [topStackView, tableView].forEach(view.addSubview)
        
        [addLabel, backButton].forEach(topStackView.addArrangedSubview)
        
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    private func presentColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = "\(viewModel.getSlices()[index].label.text ?? "") Color"
        colorPicker.supportsAlpha = false
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        self.present(colorPicker, animated: true)
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true)
    }
}

extension ColorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getSlices().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slice = viewModel.getSlices()[indexPath.row]
        
        let cell: ColorCell = tableView.dequeueCell(for: indexPath)
        
        cell.onEditButtonTapped = {[weak self] in
            self?.index = indexPath.row
            self?.presentColorPicker()
        }
        
        cell.configure(.init(categoryName: slice.label.text ?? "",
                             categoryColor: slice.color))
        
        return cell
    }
}


extension ColorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        
        // Change color
        var colorChangeSlice = viewModel.getSlices()
        colorChangeSlice[index].color = color
        viewModel.saveSlices(slices: colorChangeSlice)
        updateWheel = true
        self.tableView.reloadData()
    }
}
