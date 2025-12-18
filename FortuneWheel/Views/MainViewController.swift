//

import UIKit
import SnapKit
import Combine

final class MainViewController: BaseViewController {
    
    private let viewModel: MainViewModel
    
    private var cancellable = Set<AnyCancellable>()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.add, for: .normal)
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var settingsButton: BaseButton = {
        let button = BaseButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(settingsButton)
        view.addSubview(addButton)
        
        settingsButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.horizontalEdges.equalToSuperview().inset(14)
            make.height.equalTo(48)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(40)
        }
        
        // Insert slice data to fortune wheel
        let savedSlices = viewModel.getSlices()
        
        if !savedSlices.isEmpty {
            viewModel.saveSlices(slices: savedSlices)
            updateFortuneWheel()
            
        } else {
            showFortuneWheel()
        }
    }
    
    func showFortuneWheel() {
        viewModel.addSlice(text: "Prize 1", color: .systemRed, dropRate: 50)
        viewModel.addSlice(text: "Prize 2", color: .systemBlue, dropRate: 50)
        updateFortuneWheel()
    }
    
    private func updateFortuneWheel() {
        let fortuneWheel = FortuneWheel.init(center: CGPoint(x: self.view.frame.width / 2,
                                                             y: self.view.frame.height / 2),
                                             diameter: 300,
                                             slices: viewModel.getSlices())
        fortuneWheel.delegate = self
        self.view.addSubview(fortuneWheel)
    }
    

    @objc private func didTapSettings() {
        viewModel.navigateToSettings(in: &cancellable) {[weak self] _ in
            self?.updateFortuneWheel()
        }
    }
    
    @objc private func didTapAdd() {
        viewModel.navigateToNewCategory(in: &cancellable) {[weak self] (category, color) in
            
            self?.viewModel.appendSlice(category: category, color: color)
            self?.updateFortuneWheel()
        }
    }

}

extension MainViewController: FortuneWheelDelegate {
    func shouldSelectObject() -> Int? {
        // returns the result of the spin
        return viewModel.calculateOdds()
    }
    
    func finishSelecting(index: Int?, error: FortuneWheelError?) {
        guard let index,
              let category = viewModel.getSlices()[index].label.text else { return }
        
        // Notify user of the result
        self.showAlert(title: "Congratulations!", message: "You have won \(category)", buttonTitle: "Cool!")
    }
}

//extension MainViewController: SettingsViewDelegate {
//    func slicesChanged(slices: [Slice]) {
//        viewModel.saveSlices(slices: slices)
//        updateFortuneWheel()
//    }
//}


// MARK: - Unused code (delete before release)

//        for i in 1...10 {
//            // The images from assets naming from 1 to 5 are called here
//            let slice = Slice.init(image: UIImage.init(named: "\(i <= 5 ? i : (i - 5))") ?? UIImage.actions)
//            slice.color = .random()
//            slices.append(slice)
//        }
//        let fortuneWheel = FortuneWheel.init(center: CGPoint(x: self.view.frame.width / 2,
//                                                             y: self.view.frame.height / 2),
//                                             diameter: 300,
//                                             slices: slices)
//        fortuneWheel.delegate = self
//        self.view.addSubview(fortuneWheel)

//        let settingsVC = SettingsViewController(slices: slices)
//        settingsVC.delegate = self
//        self.present(settingsVC, animated: true)

//        let newSliceVC = NewSliceViewController()
//        newSliceVC.delegate = self
//        self.present(newSliceVC, animated: true)

//        let randomValue = Int.random(in: 1...100)
//
//        var cumulativeRate = 0
//
//        for (index, slice) in viewModel.getSlices().enumerated() {
//            cumulativeRate += slice.dropRate
//
//            if randomValue <= cumulativeRate {
//                return index
//            }
//        }
//
//        print("Falling back")
//        return 0

//        let totalRate = 100
//        var totalSlicesRate: Int = 0
//        viewModel.getSlices().forEach( { totalSlicesRate += $0.dropRate} )
//        let remainingRate = totalRate - totalSlicesRate
//        viewModel.addSlice(text: category, color: color, dropRate: remainingRate)

//    private func addSlice(text: String, color: UIColor, dropRate: Int) {
//        let label = UILabel()
//        label.text = text
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.numberOfLines = 0
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.5
//        var slice = Slice.init(label: label)
//        slice.dropRate = dropRate
//        slice.color = color
//
//        // Append new slice
//        var slices = viewModel.getSlices()
//        slices.append(slice)
//        viewModel.saveSlices(slices: slices)
//        print(slices)
//    }
