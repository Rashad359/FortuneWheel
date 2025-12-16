//

import Foundation
import UIKit
import SnapKit

// Change to combine later
protocol SettingsViewDelegate: AnyObject {
    func slicesChanged(slices: [Slice])
}

final class SettingsViewController: UIViewController {
    
    private var slices: [Slice]
    
    init(slices: [Slice]) {
        self.slices = slices
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: SettingsViewDelegate? = nil
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SliceCell.self, forCellReuseIdentifier: SliceCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateOdds(for changedSliceIndex: Int, newValue: Int) {
        let validNewValue = max(0, min(100, newValue))
        
        let remainingPool = 100 - validNewValue
        
        var currentOtherTotal = 0
        for (index, slice) in slices.enumerated() where index != changedSliceIndex {
            currentOtherTotal += slice.dropRate
        }
        
        slices[changedSliceIndex].dropRate = validNewValue
        
        var distributedTotal = 0
        
        for (index, slice) in slices.enumerated() where index != changedSliceIndex {
            if currentOtherTotal > 0 {
                let ratio = Double(slice.dropRate) / Double(currentOtherTotal)
                let newRate = Int(Double(remainingPool) * ratio)
                
                slice.dropRate = newRate
                distributedTotal += newRate
            } else {
                let otherCount = slices.count - 1
                let newRate = otherCount > 0 ? remainingPool / otherCount : 0
                slice.dropRate = newRate
                distributedTotal += newRate
            }
        }
        
        let dust = remainingPool - distributedTotal
        if dust != 0, let fixIndex = slices.indices.first(where: { $0 != changedSliceIndex } ) {
            slices[fixIndex].dropRate += dust
        }
        
        tableView.reloadData()
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate, SliceCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slice = slices[indexPath.row]
        let cell: SliceCell = tableView.dequeueCell(for: indexPath)
        cell.delegate = self
        cell.configure(.init(categoryName: slice.label.text ?? "",
                             categoryOdds: slice.dropRate))
        return cell
    }
    
    func didChangeRate(value: Int, in cell: SliceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        updateOdds(for: indexPath.row, newValue: value)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] _, _, _ in
            self?.slices.remove(at: indexPath.row)
            
            self?.delegate?.slicesChanged(slices: self?.slices ?? [])
            
            self?.tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {[weak self] _, _, _ in
            
            let alert = UIAlertController(title: "New title", message: "Please put the new title", preferredStyle: .alert)
            alert.addTextField()
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "Confirm", style: .default) { _ in
                let printedText = alert.textFields?.first?.text
                self?.slices[indexPath.row].label.text = printedText
                self?.delegate?.slicesChanged(slices: self?.slices ?? [])
                self?.tableView.reloadData()
            }
            
            [cancel, confirm].forEach(alert.addAction)
            self?.present(alert, animated: true)
        }
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
}
