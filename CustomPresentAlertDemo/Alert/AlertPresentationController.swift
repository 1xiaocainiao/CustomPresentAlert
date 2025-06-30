//
//  AlertPresentationController.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/27.
//

import UIKit

// MARK: - 核心实现
class AlertPresentationController: UIPresentationController {
    var config: AlertConfig!
    lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = config.backgroundColor
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if config.tapBackgroundDismiss {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedController))
            view.addGestureRecognizer(tap)
        }
        
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         config: AlertConfig) {
        self.config = config
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        setupKeyboardObservers()
    }
    
    @objc private func dismissPresentedController() {
        presentedViewController.dismiss(animated: true)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        
        let safeWidth = UIDevice.current.userInterfaceIdiom == .pad ? 320 : container.bounds.width - 2 * config.horizontalMargin
        let maxHeight = container.bounds.height - container.safeAreaInsets.top
        
        // 计算内容尺寸
        var contentSize = presentedViewController.view.systemLayoutSizeFitting(
            CGSize(width: safeWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        contentSize.height = min(contentSize.height, maxHeight)
        contentSize.width = safeWidth
        
        // 计算位置
        var origin: CGPoint
        
        switch config.style {
        case .alert:
            origin = CGPoint(
                x: (container.bounds.width - contentSize.width) / 2,
                y: (container.bounds.height - contentSize.height) / 2
            )
        case .actionSheet:
            origin = CGPoint(
                x: (container.bounds.width - contentSize.width) / 2,
                y: container.bounds.height - contentSize.height
            )
        }
        
        return CGRect(origin: origin, size: contentSize)
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
    }
}

// MARK: - Keyboard Handling
extension AlertPresentationController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let container = containerView,
              let presentedView = presentedView else { return }
        
        let convertedFrame = container.convert(presentedView.frame, to: nil)
        let padding: CGFloat = 20
        
        // 检查键盘是否遮挡
        if convertedFrame.maxY > (container.frame.height - keyboardFrame.height) {
            let offset = convertedFrame.maxY - (container.frame.height - keyboardFrame.height) + padding
            presentedView.frame.origin.y -= offset
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        presentedView?.frame.origin.y = ((containerView?.frame.height ?? 0) - presentedView!.frame.height ) / 2
    }
}
