//
//  AlertTransitionDelegate.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/27.
//

import UIKit

// MARK: - 转场代理
class AlertTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var config: AlertConfig
    
    init(config: AlertConfig) {
        self.config = config
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = AlertPresentationController(presentedViewController: presented, presenting: presenting, config: config)
        controller.config = config
        return controller
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if case let .customPresent( presentAnimator, _) = config.animationType,
           let customPresent = presentAnimator {
            return customPresent
        }
        
        return AlertTransitionAnimator(config: config, isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if case let .customPresent(_, dismissAnimator) = config.animationType,
           let customPresent = dismissAnimator {
            return customPresent
        }
        
        return AlertTransitionAnimator(config: config, isPresenting: false)
    }
}

