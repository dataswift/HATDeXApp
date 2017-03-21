/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Struct

///The animation controller struct
struct AnimationHelper {
    
    // MARK: - Animations
    
    /**
     Animates the ring from position 0 to the desired position
     
     - parameter duration: The duration of the animation
     - parameter arc: The arc to animate
     
     - author: Marios-Andreas Tsekis
     - date: 15/7/2016
     - version: 1.0
     - copyright: Copyright © 2016 Marios-Andreas Tsekis. All rights reserved.
     */
    static func animateCircle(_ duration: TimeInterval, arc: CAShapeLayer) {
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        arc.strokeEnd = 1.0
        
        DispatchQueue.main.async {
            
            // Do the actual animation
            arc.add(animation, forKey: "animateCircle")
        }
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     */
    static func animateView(_ view: UIView?, duration: TimeInterval, animations: @escaping (Void) -> Void, completion: @escaping (Bool) -> Void) {
        
        if view != nil {
            
            DispatchQueue.main.async {
                
                UIView.animate(
                    withDuration: duration,
                    animations: {() -> Void in
                        
                        animations()
                    },
                    completion: {(bool: Bool) -> Void in
                        
                        completion(true)
                })
            }
        }
    }
    
    // MARK: - Add blur to view
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - returns: <#Returns#>
     */
    static func addBlurToView(_ view: UIView) -> UIVisualEffectView {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let viewToReturn = UIVisualEffectView(effect: blurEffect)
        viewToReturn.frame = view.bounds
        viewToReturn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewToReturn)
        
        return viewToReturn
    }
}