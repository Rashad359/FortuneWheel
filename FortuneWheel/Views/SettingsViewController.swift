//

import Foundation
import UIKit
import SnapKit
import Combine

final class SettingsViewController: BaseViewController, Keyboardable {
    
    var targetConstraint: SnapKit.Constraint?
    
    private let viewModel: SettingsViewModel
    
    @Published private(set) var updateWheel = false
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SliceCell.self, forCellReuseIdentifier: SliceCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
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
    
    private lazy var applySettings: BaseButton = {
        let button = BaseButton(type: .system)
        button.setTitle("Apply Changes", for: .normal)
        button.addTarget(self, action: #selector(didApplyChanges), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startKeyboardObserve(with: -10)
    }
    
    override func setupUI() {
        super.setupUI()
        
        [tableView, topStackView, applySettings].forEach(view.addSubview)
        [titleLabel, backButton].forEach(topStackView.addArrangedSubview)
        
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(applySettings.snp.top).offset(-10)
        }
        
        applySettings.snp.makeConstraints { make in
            targetConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10).constraint
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        // Dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true)
    }
    
    @objc private func didApplyChanges() {
        viewModel.applyChanges {[weak self] isCorrect in
            if isCorrect {
                
                self?.viewModel.saveSlices(slices: self?.viewModel.getLocalSlices() ?? [])
                self?.updateWheel = true
                self?.dismiss(animated: true)
                
            } else {
                
                self?.showAlert(title: "Wrong odds", message: "The total odds should sum up to 100", buttonTitle: "Cancel")
                
            }
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate, SliceCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getSlices().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slice = viewModel.getSlices()[indexPath.row]
        
        let cell: SliceCell = tableView.dequeueCell(for: indexPath)
        cell.delegate = self
        cell.configure(.init(categoryName: slice.label.text ?? "",
                             categoryOdds: slice.dropRate))
        
        return cell
    }
    
    func didChangeRate(value: Int, in cell: SliceCell) {
        viewModel.changeSliceRate(value: value, in: cell, for: tableView)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] _, _, _ in
            var deletedSlices: [Slice] = self?.viewModel.getSlices() ?? []
            
            deletedSlices.remove(at: indexPath.row)
            
            self?.viewModel.saveSlices(slices: deletedSlices)
            
            self?.updateWheel = true
            
            self?.tableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {[weak self] _, _, _ in
            
            let alert = UIAlertController(title: "New title", message: "Please put the new title", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields?.first?.text = self?.viewModel.getSlices()[indexPath.row].label.text
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "Confirm", style: .default) { _ in
                let printedText = alert.textFields?.first?.text
                
                let alteredSlices: [Slice] = self?.viewModel.getSlices() ?? []
                alteredSlices[indexPath.row].label.text = printedText
                self?.viewModel.saveSlices(slices: alteredSlices)
                
                self?.updateWheel = true
                
                self?.tableView.reloadData()
            }
            
            [cancel, confirm].forEach(alert.addAction)
            self?.present(alert, animated: true)
        }
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
}


// MARK: - Unused or deprecated code (delete before release)

//        guard let indexPath = tableView.indexPath(for: cell) else { return }
////        updateOdds(for: indexPath.row, newValue: value)
//
//        // Move to view model
//        var alteredSlices = viewModel.getSlices()
//        alteredSlices[indexPath.row].dropRate = value
//        viewModel.saveLocalSlices(slices: alteredSlices)
////        slices[indexPath.row].dropRate = value
//        var newTotalSum = 0
//        viewModel.getLocalSlices().forEach( { newTotalSum += $0.dropRate } )
//
//        // Delete when not needed
//        if newTotalSum < 100 || newTotalSum > 100 {
//            // Don't save it
//            print("Don't save changes")
//        } else {
//            // The odds are right
//            print("Slice odds are right")
//        }



//    private func updateOdds(for changedSliceIndex: Int, newValue: Int) {
//        let validNewValue = max(0, min(100, newValue))
//
//        let remainingPool = 100 - validNewValue
//
//        var currentOtherTotal = 0
//        for (index, slice) in slices.enumerated() where index != changedSliceIndex {
//            currentOtherTotal += slice.dropRate
//        }
//
//        slices[changedSliceIndex].dropRate = validNewValue
//
//        var distributedTotal = 0
//
//        for (index, slice) in slices.enumerated() where index != changedSliceIndex {
//            var slice = slice
//            if currentOtherTotal > 0 {
//                let ratio = Double(slice.dropRate) / Double(currentOtherTotal)
//                let newRate = Int(Double(remainingPool) * ratio)
//
//                slice.dropRate = newRate
//                distributedTotal += newRate
//            } else {
//                let otherCount = slices.count - 1
//                let newRate = otherCount > 0 ? remainingPool / otherCount : 0
//                slice.dropRate = newRate
//                distributedTotal += newRate
//            }
//        }
//
//        let dust = remainingPool - distributedTotal
//        if dust != 0, let fixIndex = slices.indices.first(where: { $0 != changedSliceIndex } ) {
//            slices[fixIndex].dropRate += dust
//        }
//
//        tableView.reloadData()
//    }




//        var totalSum: Int = 0
//        viewModel.getLocalSlices().forEach( { totalSum += $0.dropRate } )
//
//        if totalSum > 100 || totalSum < 100 {
//            // Bring alert to the user
//            self.showAlert(title: "Wrong odds", message: "The total odds should sum up to 100", buttonTitle: "Cancel")
//        } else {
//            // Slice odds are right, changes are saved.
//            self.delegate?.slicesChanged(slices: viewModel.getLocalSlices())
//            self.dismiss(animated: true)
//        }
