//
//  CustomAlertConfig.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/27.
//

import Foundation
import UIKit

struct AlertConfig {
    enum PresentationStyle {
        case alert
        case actionSheet
    }
    
    enum AnimationType {
        case center
        case left
        case right
        case top
        case bottom
        case customPresent(present: UIViewControllerAnimatedTransitioning? = nil, dismiss: UIViewControllerAnimatedTransitioning? = nil)
    }
    
    enum DismissDirection {
        case horizontal
        case vertical
        case none
    }
    
    var style: PresentationStyle = .alert
    var animationType: AnimationType = .center
    var backgroundColor: UIColor = .black.withAlphaComponent(0.5)
    var tapBackgroundDismiss = true
    /// 为实现
    var dismissDirection: DismissDirection = .none
    var horizontalMargin: CGFloat = 24
    var cornerRadius: CGFloat = 12
    var buttonHeight: CGFloat = 44
    var textFieldHeight: CGFloat = 40
    var verticalSpacing: CGFloat = 16
    var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
    var messageFont: UIFont = UIFont.systemFont(ofSize: 16)
    var buttonFont: UIFont = UIFont.systemFont(ofSize: 16)
}








