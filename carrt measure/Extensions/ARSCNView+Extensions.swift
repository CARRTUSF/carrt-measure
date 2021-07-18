

import Foundation
import ARKit

extension ARSCNView{
    
    
    /// Adds A Ripple Effect To An ARSCNView
    func rippleView(){
        
        let animation = CATransition()
        animation.duration = 1.75
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = CATransitionType(rawValue: "rippleEffect")
        self.layer.add(animation, forKey: nil)
       
    }
}
