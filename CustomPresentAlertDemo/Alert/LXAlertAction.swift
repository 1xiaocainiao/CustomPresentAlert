//
//  DismissableButton.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/28.
//

import UIKit

class LXAlertAction {
    enum Style {
        case `default`
        case cancel
        case destructive
    }
    
    let title: String
    let style: Style
    let handler: (() -> Void)?
    var autoDismiss: Bool
    
    init(title: String, style: Style = .default, autoDismiss: Bool = true, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
        self.autoDismiss = autoDismiss
    }
}
