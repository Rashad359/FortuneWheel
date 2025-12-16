import UIKit

class Slice {
    // Color of the slice default is clear
    var color = UIColor.clear
    
    // Label to be shown in the slice
    var label: UILabel
    
    // Border line color Default color is white
    var borderColor = UIColor.white
    
    // Width of the border line.Default is 0.5
    var borderWidth: CGFloat = 1
    
    // Drop rate of the slice, Default is 0
    var dropRate: Int = 0
    
    init(label: UILabel) {
        self.label = label
    }
}
