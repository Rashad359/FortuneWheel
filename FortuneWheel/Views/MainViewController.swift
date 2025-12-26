//

import UIKit
import SnapKit
import Combine

final class MainViewController: BaseViewController {
    
    private let viewModel: MainViewModel
    
    private var cancellable = Set<AnyCancellable>()
    
    private var currentFortuneWheel: FortuneWheel?
    
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
    
    private lazy var changeColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paintbrush.pointed.fill"), for: .normal)
        button.addTarget(self, action: #selector(didTapColor), for: .touchUpInside)
        
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
        view.addSubview(changeColorButton)
        
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
        
        changeColorButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
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
    
    private func showFortuneWheel() {
        viewModel.addSlice(text: "Prize 1", color: .systemRed, dropRate: 50)
        viewModel.addSlice(text: "Prize 2", color: .systemBlue, dropRate: 50)
        updateFortuneWheel()
    }
    
    private func updateFortuneWheel() {
        
        currentFortuneWheel?.removeFromSuperview()
        
        let fortuneWheel = FortuneWheel.init(center: CGPoint(x: self.view.frame.width / 2,
                                                             y: self.view.frame.height / 2),
                                             diameter: 300,
                                             slices: viewModel.getSlices())
        fortuneWheel.delegate = self
        self.view.addSubview(fortuneWheel)
        
        self.currentFortuneWheel = fortuneWheel
    }
    

    @objc private func didTapSettings() {
        viewModel.navigateToSettings(in: &cancellable) {[weak self] updateNeeded in
            if updateNeeded {
                
                self?.viewModel.resetHistory()
                self?.updateFortuneWheel()
                
            } else {
                //Don't update
            }
        }
    }
    
    @objc private func didTapAdd() {
        viewModel.navigateToNewCategory(in: &cancellable) {[weak self] (category, color) in
            
            self?.viewModel.appendSlice(category: category, color: color)
            self?.viewModel.resetHistory()
            self?.updateFortuneWheel()
        }
    }
    
    @objc private func didTapColor() {
        viewModel.navigateToColors(storage: &cancellable) {[weak self] updateNeeded in
            if updateNeeded {
                
                self?.viewModel.resetHistory()
                self?.updateFortuneWheel()
                
            } else {
                //Don't update
            }
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
