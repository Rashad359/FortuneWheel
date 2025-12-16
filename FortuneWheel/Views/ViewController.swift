//

import UIKit
import SnapKit

final class ViewController: UIViewController {
    
    private var slices = [Slice]()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.add, for: .normal)
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change the odds", for: .normal)
        button.backgroundColor = .link
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        showFortuneWheel()
        
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
    }
    
    private func addSlice(text: String, color: UIColor, dropRate: Int) {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        let slice = Slice.init(label: label)
        slice.dropRate = dropRate
        slice.color = color
        slices.append(slice)
    }
    
    private func updateFortuneWheel() {
        let fortuneWheel = FortuneWheel.init(center: CGPoint(x: self.view.frame.width / 2,
                                                             y: self.view.frame.height / 2),
                                             diameter: 300,
                                             slices: slices)
        fortuneWheel.delegate = self
        self.view.addSubview(fortuneWheel)
    }
    
    // Assign the center CGPoint for the wheel and a diameter and the slices it should show and conform to the protocol
    func showFortuneWheel() {
        addSlice(text: "Prize 1", color: .systemRed, dropRate: 50)
        addSlice(text: "Prize 2", color: .systemBlue, dropRate: 50)
        updateFortuneWheel()
    }

    @objc private func didTapSettings() {
        
        // Change to coordinator or router later
        let settingsVC = SettingsViewController(slices: slices)
        settingsVC.delegate = self
        self.present(settingsVC, animated: true)
    }
    
    @objc private func didTapAdd() {
        let newSliceVC = NewSliceViewController()
        newSliceVC.delegate = self
        self.present(newSliceVC, animated: true)
    }

}

extension ViewController: FortuneWheelDelegate {
    func shouldSelectObject() -> Int? {
        // returns the result of the spin
        
        let randomValue = Int.random(in: 1...100)
        
        var cumulativeRate = 0
        
        for (index, slice) in slices.enumerated() {
            cumulativeRate += slice.dropRate
            
            if randomValue <= cumulativeRate {
                return index
            }
        }
        
        print("Falling back")
        return 0
    }
    
    func finishSelecting(index: Int?, error: FortuneWheelError?) {
        guard let index,
              let category = slices[index].label.text else { return }
        
        // Notify user of the result
        let alertController = UIAlertController(title: "Congratulatoins", message: "You have won \(category)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Cool!", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
}

extension ViewController: NewSliceViewDelegate {
    func didAddSlice(with category: String, color: UIColor) {
        let totalRate = 100
        var totalSlicesRate: Int = 0
        slices.forEach( { totalSlicesRate += $0.dropRate} )
        let remainingRate = totalRate - totalSlicesRate
        addSlice(text: category, color: color, dropRate: remainingRate)
        updateFortuneWheel()
    }
}

extension ViewController: SettingsViewDelegate {
    func slicesChanged(slices: [Slice]) {
        self.slices = slices
        updateFortuneWheel()
    }
}
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
