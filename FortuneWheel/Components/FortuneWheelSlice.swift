//

import Foundation
import UIKit

typealias Radians = CGFloat

typealias Degree = CGFloat

class FortuneWheelSlice: CALayer {
    
    // Angle where the slice begins.
    private var startAngle: Radians!
    
    // Total angle the sector covers
    private var sectorAngle: Radians = -1
    
    // Slice object which contains the slice data.
    private var slice: Slice!
    
    
    // Start angle is the angle where the sector begins and sector angle is the angle, the sector covers
    init(frame: CGRect, startAngle: CGFloat, sectorAngle: CGFloat, slice: Slice) {
        super.init()
        
        self.startAngle = startAngle
        self.sectorAngle = sectorAngle
        self.slice = slice
        self.frame = frame.inset(by: UIEdgeInsets.init(top: -10, left: 0, bottom: -10, right: 0))
        
        // Images where appearing distorted setting the scale solved the issue
        self.contentsScale = UITraitCollection.current.displayScale
        self.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(in ctx: CGContext) {
        
        //Rotated Image
//        let image = self.slice.image.rotateImage(angle: self.startAngle)!
        let label = self.slice.label
        
        // The radius of the wheel
        let radius = self.frame.width / 2 - self.slice.borderWidth
        
        // Length of the third line in the isosceles triangle.Calculated using chord length formula.
        let lineLength = CGFloat( (2 * radius * sin(self.sectorAngle / 2)) )
        
        // The center position of the wheel
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        // Half perimeter used for calculation of size
        let s = (radius + radius + lineLength) / 2
        
        // Size calculations based on Incenter radius for isosceles triangle formula. Increase the size by 1.5 instead of 2 (as the calculation gives radius and we need diameter) to adjust the image properly inside the slice.
        let inCenterDiameter = ((s * (s - radius) * (s - radius) * (s - lineLength)).squareRoot() / s) * 1.50
        
        // The size of image square
        var size: CGFloat = 0
        
        // Size for 180, 120 and 90 degrees is adjusted manually to properly utilize the space
        size = self.sectorAngle == Degree(180).toRadians() ? radius / 2 : self.sectorAngle == Degree(120).toRadians() ? radius / 1.9 : self.sectorAngle == Degree(90).toRadians() ? radius / 1.9 : inCenterDiameter
        
        // Reducing the border width of the lines in size
        size -= self.slice.borderWidth * 3
        
        // Gap between chord and circumference of the circle at the center of the sector
        let height = 2 * (1 - cos(self.sectorAngle / 2))
        
        // X position of the Incenter of a isosceles triangle. Moved outside a bit to remove the Overlay of image over line
        let xIncenter = ((radius * radius) + ((radius * cos(self.sectorAngle)) * radius)) / (radius + radius + lineLength) + (size * 0.07)
        
        // Y position of the incenter of a isosceles triangle
        let yIncenter = ((radius * sin(self.sectorAngle)) * radius) / (radius + radius + lineLength)
        
        // Center alignment of image 180, 120, 90 degrees positions are adjusted manually
        let _ : CGFloat = self.sectorAngle == Degree(180).toRadians() ? (-size/2) : self.sectorAngle == Degree(120).toRadians() ? (radius/2.7 - size/2) : self.sectorAngle == Degree(90).toRadians() ? (radius/2.4 - size/2) : ((xIncenter - size/2) + height)
//
        let _ : CGFloat = self.sectorAngle == Degree(180).toRadians() ? size/1.6 : self.sectorAngle == Degree(120).toRadians() ? (radius/2 - size/2) : self.sectorAngle == Degree(90).toRadians() ? (radius/2.4 - size/2) : (yIncenter - size/2)
        
        // Drawing the slice
        
        UIGraphicsPushContext(ctx)
        
        let path = UIBezierPath.init()
        path.lineWidth = self.slice.borderWidth
        path.move(to: center)
        path.addArc(withCenter: center,
                    radius: radius,
                    startAngle: self.startAngle,
                    endAngle: self.startAngle + self.sectorAngle,
                    clockwise: true)
        path.close()
        // Applies the slice color
        self.slice.color.setFill()
        path.fill()
        // Applies border color
        self.slice.borderColor.setStroke()
        path.stroke()
        
        // Image draw
        
        ctx.saveGState()
        ctx.translateBy(x: center.x,
                        y: center.y)
        ctx.rotate(by: self.startAngle + self.sectorAngle / 2)
        
        let labelDistance = radius * 0.6
        let labelSize = CGSize(width: radius * 0.8, height: 40)
        let labelRect = CGRect(x: labelDistance - labelSize.width / 2,
                               y: -labelSize.height / 2,
                               width: labelSize.width,
                               height: labelSize.height)
        
        label.drawText(in: labelRect)
        UIGraphicsPopContext()
    }
    
    
}

extension Degree {
    func toRadians() -> Radians {
        return (self * .pi) / 180.0
    }
}
