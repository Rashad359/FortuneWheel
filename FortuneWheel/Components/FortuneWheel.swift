//

import UIKit

protocol FortuneWheelDelegate: NSObject {
    // Returns the index which should be selected when the user taps the spin button to start the game. Default value is -1
    // Index which should be selected for array slices
    func shouldSelectObject() -> Int?
    
    // Indicates the finishing of the game
    func finishSelecting(index: Int?, error: FortuneWheelError?)
}


// Makes the delegate optional
extension FortuneWheelDelegate {
    func finishSelecting(index: Int?, error: FortuneWheelError?) {
        
    }
}

class FortuneWheel: UIView {
    
    weak var delegate: FortuneWheelDelegate?
    
    var selectionIndex: Int = -1
    
    // Size of the image view that indicates which slice has been selected
    private lazy var indicatorSize: CGSize = {
        let size = CGSize.init(width: self.bounds.width * 0.126, height: self.bounds.height * 0.126)
        return size
    }()
    
    // The number of slices the wheel has to be divided into is determined by this array count each slice object contains its corresponding slices data.
    private var slices : [Slice]?
    
    // ImageView that holds an image which indicates which slice has been selected.
    private var indicator = UIImageView()
    
    // Button which start the spin game. This is placed at the center of the wheel.
    var playButton: UIButton = UIButton(type: .custom)
    
    // Angle each slice occupies
    private var sectorAngle: Radians = 0
    
    // This variable stores the selection angle calculated in the perform selection method which will by used to transform the wheel view when animation completes
    private var selectionAngle: Radians = 0

    
    // The view on which the slices will be drawn. This view will be rotated to simulate the spin
    private var wheelView: UIView!
    
    // Creates and returns a Fortune Wheel with its center aligned to center CGPoint, diameter and slices drawn
    init(center: CGPoint, diameter: CGFloat, slices: [Slice]) {
        super.init(frame: CGRect(origin: CGPoint(x: center.x - diameter / 2,
                                                 y: center.y - diameter / 2),
                                                 size: CGSize.init(width: diameter,
                                                                   height: diameter)))
        self.slices = slices
        self.initialSetUp()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        let scale = self.window?.screen.scale ?? UITraitCollection.current.displayScale
        
        self.layer.sublayers?.forEach { layer in
            layer.contentsScale = scale
            layer.setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // The setup of the fortune wheel is done here.
    private func initialSetUp() {
        self.backgroundColor = .clear
        self.addWheelView()
        self.addStartBttn()
        self.addIndicator()
    }
    
    // Adds the wheel view which has the slices.
    private func addWheelView() {
        
        let width = self.bounds.width - self.indicatorSize.width
        let height = self.bounds.height - self.indicatorSize.height
        
        // Calculating x,y positions such that wheel view is aligned with FortuneWheel at the center
        let xPosition: CGFloat = (self.bounds.width / 2) - (width / 2)
        let yPosition: CGFloat = (self.bounds.height / 2) - (height / 2)
        
        self.wheelView = UIView(frame: CGRect.init(x: xPosition,
                                                   y: yPosition,
                                                    width: width,
                                                    height: height))
        self.wheelView.backgroundColor = .gray
        self.wheelView.layer.cornerRadius = width / 2
        self.wheelView.clipsToBounds = true
        self.addSubview(self.wheelView)
        
        self.addWheelLayer()
    }
    
    private func addWheelLayer() {
        // We check if the slices array exists or not. If not, we show an error.
        if let slices = self.slices {
            // We check if there are at least 2 slices in the array. If not, we show an error.
            if slices.count >= 2 {
                self.wheelView.layer.sublayers?.forEach( { $0.removeFromSuperlayer() })
                
                // #1
                self.sectorAngle = (2 * CGFloat.pi) / CGFloat(slices.count)
                
                // #2
                for (index, slice) in slices.enumerated() {
                    // we will get this class in a moment. For now ignore the errors
                    let sector = FortuneWheelSlice.init(frame: self.wheelView.bounds,
                                                        startAngle: self.sectorAngle * CGFloat(index),
                                                        sectorAngle: self.sectorAngle,
                                                        slice: slice)
                    
                    self.wheelView.layer.addSublayer(sector)
                    sector.setNeedsDisplay()
                }
                
            } else {
                let error = FortuneWheelError.init(message: "Not enough slices. Should have at least two slices", code: 0)
                
                // #3
                self.performFinish(error: error)
            }
        }
    }
    
    private func performFinish(error: FortuneWheelError?) {
        if let error {
            self.delegate?.finishSelecting(index: nil, error: error)
        } else {
            // When the animation is complete transform fixes the view position to selection angle
            self.wheelView.transform = CGAffineTransform(rotationAngle: self.selectionAngle)
            self.delegate?.finishSelecting(index: self.selectionIndex, error: nil)
        }
        
        if !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        }
    }
    
    // Add selection indicator
    private func addIndicator() {
        //Calculating the position of the indicator such that half overlaps with the view and the rest is outside of the view and locating indicator at the right side center of the wheel.
        let position = CGPoint(x: self.frame.width - self.indicatorSize.width,
                               y: self.bounds.height / 2 - self.indicatorSize.height / 2)
        
        self.indicator.frame = CGRect(origin: position,
                                      size: self.indicatorSize)
        self.indicator.image = UIImage(systemName: "arrowtriangle.left.fill")
        self.indicator.tintColor = .black
        if self.indicator.superview == nil {
            self.addSubview(self.indicator)
        }
    }
    
    private func addStartBttn() {
        let size = CGSize(width: self.bounds.width * 0.15,
                          height: self.bounds.height * 0.15)
        let point = CGPoint(x: self.frame.width / 2 - size.width / 2,
                            y: self.frame.height / 2 - size.height / 2)
        self.playButton.setTitle("Play", for: .normal)
        self.playButton.frame = CGRect(origin: point, size: size)
        
        // we will add the StartAction method later on
        self.playButton.addTarget(self, action: #selector(startAction), for: .touchUpInside)
        self.playButton.layer.cornerRadius = self.playButton.frame.height / 2
        self.playButton.clipsToBounds = true
        self.playButton.backgroundColor = .gray
        self.playButton.layer.borderWidth = 0.5
        self.playButton.layer.borderColor = UIColor.white.cgColor
        self.addSubview(self.playButton)
    }
    
    @objc private func startAction() {
        self.playButton.isEnabled = false
        
        if let slicesCount = self.slices?.count {
            // Asks the delegate for index which should be selected. If returned assigned to selectedIndex variable
            if let index = self.delegate?.shouldSelectObject() {
                self.selectionIndex = index
            }
            
            if (self.selectionIndex >= 0 && self.selectionIndex < slicesCount) {
                self.performSelection()
            } else {
                let error = FortuneWheelError.init(message: "Invalid selection index", code: 0)
                self.performFinish(error: error)
            }
        } else {
            let error = FortuneWheelError(message: "No Slices", code: 0)
            self.performFinish(error: error)
        }
    }
    
    func performSelection() {
        
        let currentRotation = atan2(self.wheelView.transform.b, self.wheelView.transform.a)
        
        let fullCircle = CGFloat.pi * 2
        let sectorAngleCGFloat = CGFloat(self.sectorAngle)
        
        self.selectionAngle = Degree(360).toRadians() - (self.sectorAngle * CGFloat(self.selectionIndex))
        let borderOffset = sectorAngleCGFloat * 0.1
        self.selectionAngle -= Radians.random(in: borderOffset...(self.sectorAngle - borderOffset))
        
        var targetAngle = fullCircle - (sectorAngleCGFloat * CGFloat(self.selectionIndex))
        
        targetAngle = targetAngle.truncatingRemainder(dividingBy: fullCircle)
        
        
        let randomOffset = CGFloat.random(in: borderOffset...(sectorAngleCGFloat - borderOffset))
        targetAngle -= randomOffset
        
        if targetAngle < 0 {
            targetAngle += fullCircle
        }
        
        var angleDifference = targetAngle - currentRotation
        
        while angleDifference < 0 {
            angleDifference += fullCircle
        }
        
        self.selectionAngle = Radians(targetAngle)
        
        let extraRotations: CGFloat = fullCircle * 4.0
        let totalRotation = currentRotation + angleDifference + extraRotations
        
        self.selectionAngle = Radians(targetAngle)
        
        let spinAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        spinAnimation.fromValue = currentRotation
        spinAnimation.toValue = totalRotation
        
        spinAnimation.duration = 4.5
        
        spinAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        spinAnimation.fillMode = .forwards
        spinAnimation.isRemovedOnCompletion = false
        spinAnimation.delegate = self
        
        self.wheelView.layer.removeAllAnimations()
        self.wheelView.layer.add(spinAnimation, forKey: "spinAnimation")
        
    }
}

extension FortuneWheel: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.performFinish(error: nil)
        } else {
            let error = FortuneWheelError(message: "Error performing selection", code: 0)
            self.performFinish(error: error)
        }
    }
}

extension FortuneWheel {
    private func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
}


// MARK: - Error handler

class FortuneWheelError: Error {
    let message: String
    let code: Int
    init(message: String, code: Int) {
        self.message = message
        self.code = code
    }
}


// MARK: - Unused or deprecated code (delete before release)


// If selection angle is negative, it's changed to positive. Negative value spins wheel in reverse direction
//        var selectionSpinDuration: Double = 1
//        let borderOffset = self.sectorAngle * 0.1
//        if self.selectionAngle < 0 {
//            self.selectionAngle = Degree(360).toRadians() + self.selectionAngle
//            selectionSpinDuration += 0.5
//        }

//        var delay: Double = 0

// Rotates view fast which simulates spin of the wheel
//        let fastSpin = CABasicAnimation.init(keyPath: "transform.rotation")
//        fastSpin.fromValue = NSNumber.init(floatLiteral: 0)
//        fastSpin.toValue = NSNumber.init(floatLiteral: .pi * 2)
//        fastSpin.duration = 0.7
//        fastSpin.repeatCount = 3
//        fastSpin.beginTime = CACurrentMediaTime() + delay
//        delay += Double(fastSpin.duration) * Double(fastSpin.repeatCount)

// Slows down the spin a bit to indicate stopping. starts immediately after fast spin is completed.
//        let slowSpin = CABasicAnimation.init(keyPath: "transform.rotation")
//        slowSpin.fromValue = NSNumber.init(floatLiteral: 0)
//        slowSpin.toValue = NSNumber.init(floatLiteral: .pi * 2)
//        slowSpin.isCumulative = true
//        slowSpin.beginTime = CACurrentMediaTime() + delay
//        slowSpin.repeatCount = 1
//        slowSpin.duration = 1.5
//        delay += Double(slowSpin.duration) * Double(slowSpin.repeatCount)

// Rotates wheel to the slice which should be selected. Starts immediately after slow spin.
//        let selectionSpin = CABasicAnimation.init(keyPath: "transform.rotation")
//        selectionSpin.delegate = self
//        selectionSpin.fromValue = NSNumber.init(floatLiteral: 0)
//        selectionSpin.toValue = NSNumber.init(floatLiteral: Double(self.selectionAngle))
//        selectionSpin.duration = selectionSpinDuration
//        selectionSpin.beginTime = CACurrentMediaTime() + delay
//        selectionSpin.isCumulative = true
//        selectionSpin.repeatCount = 1
//        selectionSpin.isRemovedOnCompletion = false
//        selectionSpin.fillMode = .forwards

// Animation is added to layer.
//        self.wheelView.layer.add(fastSpin, forKey: "fastAnimation")
//        self.wheelView.layer.add(slowSpin, forKey: "slowAnimation")
//        self.wheelView.layer.add(selectionSpin, forKey: "selectionAnimation")
