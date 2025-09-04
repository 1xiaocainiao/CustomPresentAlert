import UIKit

/// 注意 目前的实现 cancel类型只能有一个，多个也只会显示一个cancel
class LXAlertController: UIViewController {
    private let contentView = UIView()
    
    private static let mainStackSpacing: CGFloat = 16
    private static let mainStackTop: CGFloat = 24
    private static let mainStackBottom: CGFloat = 24
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = LXAlertController.mainStackSpacing
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let messageLabel: UITextView = {
        let label = UITextView()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.isScrollEnabled = false
        
        let padding = label.textContainer.lineFragmentPadding
        label.textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        return label
    }()
    private var messageHeightConstraint: NSLayoutConstraint!
    
    private let actionSheetScrollContinar = UIView()
    private let actionSheetScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    private let actionSheetScrollStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 12
        return stack
    }()
    
    private let customViewContainer = UIView()
    
    private let alertActionButtonContainer = UIView()
    private let alertActionButtonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    private let actionSheetCancelButtonContainer = UIView()
    
    private let config: AlertConfig
    private var textFields: [UITextField] = []
    private var actions: [LXAlertAction] = []
    
    private let transitionDelegate: AlertTransitionDelegate
    
    private var isActionSheetMode: Bool {
        return config.style == .actionSheet
    }
    
    private var shouldUseHorizontalButtons: Bool {
        return config.style == .alert && actions.count == 2
    }
    
    private var scrollContainerHeightConstraint: NSLayoutConstraint?
    
    private let actionSheetCancelTopSpacingToContentView: CGFloat = 16.0
    private let actionSheetCancelBottomSpacing: CGFloat = 16.0
    private let actionSheetTopSpacingToSafeArea: CGFloat = 30.0
    
    deinit {
        #if DEBUG
        print("LXAlertController 已被销毁")
        #endif
    }
    
    init(title: String?, message: String?, config: AlertConfig) {
        self.config = config
        self.transitionDelegate = AlertTransitionDelegate(config: config)
        
        super.init(nibName: nil, bundle: nil)
        
        self.titleLabel.text = title
        self.messageLabel.text = message
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transitionDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMessageAndContentHeight()
    }
    
    @discardableResult
    func addTextField(placeholder: String?) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textFields.append(textField)
        return textField
    }
    
    func addAction(_ action: LXAlertAction) {
        actions.append(action)
        configureButtons()
    }
    
    func addCustomView(_ view: UIView) {
        customViewContainer.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        customViewContainer.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: customViewContainer.topAnchor),
            view.leadingAnchor.constraint(equalTo: customViewContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: customViewContainer.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: customViewContainer.bottomAnchor)
        ])
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = config.cornerRadius
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
        
        if let title = titleLabel.text, !title.isEmpty {
            mainStackView.addArrangedSubview(titleLabel)
        }
        
        if let message = messageLabel.text, !message.isEmpty {
            mainStackView.addArrangedSubview(messageLabel)
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageHeightConstraint = messageLabel.heightAnchor.constraint(equalToConstant: 0)
        }
        
        if isActionSheetMode {
            setupScrollContainer()
        } else {
            if !customViewContainer.subviews.isEmpty {
                mainStackView.addArrangedSubview(customViewContainer)
            }
            
            for textField in textFields {
                mainStackView.addArrangedSubview(textField)
            }
        }
        
        alertActionButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(alertActionButtonContainer)
        
        // 取消按钮容器（仅actionSheet）
        if isActionSheetMode {
            actionSheetCancelButtonContainer.translatesAutoresizingMaskIntoConstraints = false
            actionSheetCancelButtonContainer.backgroundColor = contentView.backgroundColor
            actionSheetCancelButtonContainer.layer.cornerRadius = config.cornerRadius
            actionSheetCancelButtonContainer.clipsToBounds = true
            view.addSubview(actionSheetCancelButtonContainer)
        }
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.mainStackTop),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.mainStackBottom),
        ])
        
        if !isActionSheetMode {
            NSLayoutConstraint.activate([
                contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                contentView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 0),
                contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: 0)
            ])
        }
        
        else {
            NSLayoutConstraint.activate([
                contentView.bottomAnchor.constraint(equalTo: actionSheetCancelButtonContainer.topAnchor, constant: -actionSheetCancelTopSpacingToContentView),
                contentView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 0),
                
                actionSheetCancelButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                actionSheetCancelButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                actionSheetCancelButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -actionSheetCancelBottomSpacing),
                actionSheetCancelButtonContainer.heightAnchor.constraint(equalToConstant: 54)
            ])
        }
        
        configureButtons()
    }
    
    private func setupScrollContainer() {
        actionSheetScrollContinar.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(actionSheetScrollContinar)
        
        actionSheetScrollView.translatesAutoresizingMaskIntoConstraints = false
        actionSheetScrollContinar.addSubview(actionSheetScrollView)
        
        actionSheetScrollStackView.translatesAutoresizingMaskIntoConstraints = false
        actionSheetScrollView.addSubview(actionSheetScrollStackView)
        
        if !customViewContainer.subviews.isEmpty {
            actionSheetScrollStackView.addArrangedSubview(customViewContainer)
        }
        
        for textField in textFields {
            actionSheetScrollStackView.addArrangedSubview(textField)
        }
        
        NSLayoutConstraint.activate([
            actionSheetScrollView.topAnchor.constraint(equalTo: actionSheetScrollContinar.topAnchor),
            actionSheetScrollView.leadingAnchor.constraint(equalTo: actionSheetScrollContinar.leadingAnchor),
            actionSheetScrollView.trailingAnchor.constraint(equalTo: actionSheetScrollContinar.trailingAnchor),
            actionSheetScrollView.bottomAnchor.constraint(equalTo: actionSheetScrollContinar.bottomAnchor),
            
            actionSheetScrollStackView.topAnchor.constraint(equalTo: actionSheetScrollView.topAnchor),
            actionSheetScrollStackView.leadingAnchor.constraint(equalTo: actionSheetScrollView.leadingAnchor),
            actionSheetScrollStackView.trailingAnchor.constraint(equalTo: actionSheetScrollView.trailingAnchor),
            actionSheetScrollStackView.bottomAnchor.constraint(equalTo: actionSheetScrollView.bottomAnchor),
            actionSheetScrollStackView.widthAnchor.constraint(equalTo: actionSheetScrollView.widthAnchor)
        ])
        
        scrollContainerHeightConstraint = actionSheetScrollContinar.heightAnchor.constraint(equalToConstant: 0)
        scrollContainerHeightConstraint?.priority = .defaultHigh
        scrollContainerHeightConstraint?.isActive = true
    }
    
    private func configureAppearance() {
        contentView.backgroundColor = .white
        
        titleLabel.textColor = .black
        
        messageLabel.textColor = .darkGray
    }
    
    private func configureButtons() {
        // 清空现有按钮
        alertActionButtonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        alertActionButtonStackView.removeFromSuperview()
        actionSheetCancelButtonContainer.subviews.forEach { $0.removeFromSuperview() }
        
        alertActionButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        alertActionButtonContainer.addSubview(alertActionButtonStackView)
        
        alertActionButtonStackView.axis = shouldUseHorizontalButtons ? .horizontal : .vertical
        alertActionButtonStackView.distribution = shouldUseHorizontalButtons ? .fillEqually : .fill
        alertActionButtonStackView.spacing = shouldUseHorizontalButtons ? 16 : 8
        
        actionSheetScrollStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let nonCancelActions = actions.filter { $0.style != .cancel }
        for action in nonCancelActions {
            let button = createButton(for: action)
            if isActionSheetMode {
                actionSheetScrollStackView.addArrangedSubview(button)
            } else {
                alertActionButtonStackView.addArrangedSubview(button)
            }
        }
        
        if isActionSheetMode {
            if let cancelAction = actions.first(where: { $0.style == .cancel }) {
                let button = createButton(for: cancelAction)
                actionSheetCancelButtonContainer.addSubview(button)
                
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: actionSheetCancelButtonContainer.topAnchor, constant: 0),
                    button.leadingAnchor.constraint(equalTo: actionSheetCancelButtonContainer.leadingAnchor, constant: 0),
                    button.trailingAnchor.constraint(equalTo: actionSheetCancelButtonContainer.trailingAnchor, constant: 0),
                    button.bottomAnchor.constraint(equalTo: actionSheetCancelButtonContainer.bottomAnchor, constant: 0)
                ])
            }
        }
        else if let cancelAction = actions.first(where: { $0.style == .cancel }) {
            let button = createButton(for: cancelAction)
            
            // 水平布局特殊处理
            if shouldUseHorizontalButtons {
                alertActionButtonStackView.insertArrangedSubview(button, at: 0)
            } else {
                alertActionButtonStackView.addArrangedSubview(button)
            }
        }
        
        NSLayoutConstraint.activate([
            alertActionButtonStackView.topAnchor.constraint(equalTo: alertActionButtonContainer.topAnchor),
            alertActionButtonStackView.leadingAnchor.constraint(equalTo: alertActionButtonContainer.leadingAnchor),
            alertActionButtonStackView.trailingAnchor.constraint(equalTo: alertActionButtonContainer.trailingAnchor),
            alertActionButtonStackView.bottomAnchor.constraint(equalTo: alertActionButtonContainer.bottomAnchor)
        ])
        
        updateMessageAndContentHeight()
    }
    
    private func updateMessageAndContentHeight() {
        self.view.layoutIfNeeded()
        
        let window = view.window ?? UIApplication.shared.windows.first ?? UIWindow()
        let topInset = window.safeAreaInsets.top
        let bottomInset = window.safeAreaInsets.bottom
        
        /// 排除内容的间距，内容高度
        var height: CGFloat = actionSheetTopSpacingToSafeArea + Self.mainStackTop + Self.mainStackBottom
        if let title = titleLabel.text, !title.isEmpty {
            let titleHeight = titleLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            height += titleHeight
        }
        if let msg = messageLabel.text, !msg.isEmpty {
            let messageHeight = messageLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            
            height += mainStackView.spacing
            
            height += messageHeight
        }
        
        if isActionSheetMode {
            alertActionButtonContainer.isHidden = alertActionButtonStackView.arrangedSubviews.isEmpty
            
            height += mainStackView.spacing
            
            let actionSheetContentHeight = actionSheetScrollStackView.systemLayoutSizeFitting(
                CGSize(width: actionSheetScrollStackView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
            
            height += actionSheetCancelTopSpacingToContentView
            let cancelHeight = actionSheetCancelButtonContainer.bounds.height
            height += cancelHeight
            /// actionSheet内容最大高度
            let actionSheetContentMaxHeight = window.bounds.height - topInset - bottomInset - height
            
            let newHeight = min(actionSheetContentHeight, actionSheetContentMaxHeight)
            scrollContainerHeightConstraint?.constant = newHeight
            
            actionSheetScrollView.isScrollEnabled = actionSheetContentHeight > actionSheetContentMaxHeight
        } else {
            if !textFields.isEmpty {
                height += CGFloat(textFields.count) * mainStackView.spacing
            }
            
            let alertBtnHeight = alertActionButtonContainer.bounds.height
            height += mainStackView.spacing
            height += alertBtnHeight
            
            let messageMaxHeight = window.bounds.height - topInset - bottomInset - height
            
            let messageHeight = messageLabel.systemLayoutSizeFitting(
                CGSize(width: messageLabel.bounds.width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
            
            let newHeight = min(messageHeight, messageMaxHeight)
            messageHeightConstraint.constant = newHeight
            
            messageLabel.isScrollEnabled = messageHeight > messageMaxHeight
        }
        
        contentView.layoutIfNeeded()
    }
    
    private func createButton(for action: LXAlertAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        switch action.style {
        case .cancel:
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = UIColor(white: 0.9, alpha: 1)
        case .destructive:
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .red
        default:
            if config.style == .alert {
                button.setTitleColor(.blue, for: .normal)
                button.backgroundColor = .clear
            } else {
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .white
            }
        }
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
              let action = actions.first(where: { $0.title == title }) else { return }
        
        action.handler?()
        
        if action.autoDismiss {
            dismiss(animated: true)
        }
    }
}


