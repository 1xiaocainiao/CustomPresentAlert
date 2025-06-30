//
//  CustomPresentAnimator.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/28.
//

import UIKit
// 自定义弹出动画
class CustomPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.5 }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let container = transitionContext.containerView
        
        toView.transform = CGAffineTransform(rotationAngle: .pi)
        toView.alpha = 0
        container.addSubview(toView)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            animations: {
                toView.transform = .identity
                toView.alpha = 1
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// 自定义消失动画
class CustomDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.4 }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        UIView.animate(
            withDuration: 0.4,
            animations: {
                fromView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                fromView.alpha = 0
            },
            completion: { _ in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
