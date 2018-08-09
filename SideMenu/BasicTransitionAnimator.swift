//
//  TransitionAnimator.swift
//  SideMenu
//
//  Created by kukushi on 2018/8/8.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

// Built-In Animation Controller
public class BasicTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let animationOptions: UIView.AnimationOptions
    
    public init(options: UIView.AnimationOptions = .transitionCrossDissolve) {
        animationOptions = options
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        transitionContext.containerView.addSubview(toViewController.view)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.transition(from: fromViewController.view,
                          to: toViewController.view,
                          duration: duration,
                          options: animationOptions
        ) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
