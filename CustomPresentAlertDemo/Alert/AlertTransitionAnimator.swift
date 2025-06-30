//
//  AlertTransitionAnimator.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/27.
//

import UIKit
// MARK: - 动画控制器
class AlertTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let config: AlertConfig
    let isPresenting: Bool
    
    init(config: AlertConfig, isPresenting: Bool) {
        self.config = config
        self.isPresenting = isPresenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if isPresenting {
            containerView.addSubview(toVC.view)
            let finalFrame = transitionContext.finalFrame(for: toVC)
            
            switch config.animationType {
            case .center:
                toVC.view.alpha = 0
                toVC.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            case .left:
                toVC.view.frame = finalFrame.offsetBy(dx: -finalFrame.width, dy: 0)
            case .right:
                toVC.view.frame = finalFrame.offsetBy(dx: finalFrame.width, dy: 0)
            case .top:
                toVC.view.frame = finalFrame.offsetBy(dx: 0, dy: -finalFrame.height)
            case .bottom:
                toVC.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
            default:
                toVC.view.alpha = 0
            }
            
            UIView.animate(withDuration: duration, animations: {
                switch self.config.animationType {
                case .center:
                    toVC.view.alpha = 1
                    toVC.view.transform = .identity
                default:
                    toVC.view.frame = finalFrame
                    toVC.view.alpha = 1
                }
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            let initialFrame = transitionContext.initialFrame(for: fromVC)
            var finalFrame = initialFrame
            
            switch config.animationType {
            case .center:
                fromVC.view.alpha = 1
            case .left:
                finalFrame = initialFrame.offsetBy(dx: -initialFrame.width, dy: 0)
            case .right:
                finalFrame = initialFrame.offsetBy(dx: initialFrame.width, dy: 0)
            case .top:
                finalFrame = initialFrame.offsetBy(dx: 0, dy: -initialFrame.height)
            case .bottom:
                finalFrame = initialFrame.offsetBy(dx: 0, dy: initialFrame.height)
            default: break
            }
            
            UIView.animate(withDuration: duration, animations: {
                switch self.config.animationType {
                case .center:
                    fromVC.view.alpha = 0
                    fromVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                case .customPresent:
                    fromVC.view.alpha = 0
                default:
                    fromVC.view.frame = finalFrame
                }
            }) { _ in
                fromVC.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
