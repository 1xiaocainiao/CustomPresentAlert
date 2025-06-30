//
//  ViewController.swift
//  CustomPresentAlertDemo
//
//  Created by mac on 2025/6/27.
//

import UIKit

class ViewController: UIViewController {
    lazy var stackView: UIStackView = UIStackView().then {
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    
    func createBtn(title: String, selector: Selector) -> UIButton {
        let btn = UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(.red, for: .normal)
            $0.addTarget(self, action: selector, for: .touchUpInside)
        }
        return btn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.view.backgroundColor = .lightGray
        
        self.view.addSubview(stackView)
        let btn1 = createBtn(title: "showCustom", selector: #selector(showCustom))
        let btn2 = createBtn(title: "showAlert", selector: #selector(showAlert))
        let btn4 = createBtn(title: "showInputAlert", selector: #selector(showInputAlert))
        let btn3 = createBtn(title: "showActionSheet", selector: #selector(showActionSheet))
        stackView.addArrangedSubview(btn1)
        stackView.addArrangedSubview(btn2)
        stackView.addArrangedSubview(btn3)
        stackView.addArrangedSubview(btn4)
        
        stackView.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 90)
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Do any additional setup after loading the view.
    }
    
    @objc func showCustom() {
        var config = AlertConfig()
        config.style = .alert
        config.cornerRadius = 18
        config.horizontalMargin = 30
        
        let alert = LXAlertController(title: "自定义视图",
                                      message: "这是一个包含自定义视图的弹窗示例",
                                      config: config)
        
        // 创建自定义视图
        let customView = createCustomRatingView()
        alert.addCustomView(customView)
        
        // 添加垂直排列的按钮
        alert.addAction(LXAlertAction(title: "好的", style: .destructive))
        alert.addAction(LXAlertAction(title: "了解", style: .default))
        alert.addAction(LXAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc func showAlert() {
        var config = AlertConfig()
        config.style = .alert
        config.cornerRadius = 14
        
        let alert = LXAlertController(title: "操作确认",
                                      message: "您确定要进行此操作吗？此操作将不可恢复。",
                                      config: config)
        
        // 添加按钮 - 只有两个按钮时水平排列
        alert.addAction(LXAlertAction(title: "测试", style: .cancel))
        alert.addAction(LXAlertAction(title: "取消", style: .cancel))
        alert.addAction(LXAlertAction(title: "确认", style: .destructive, handler: {
            print("用户确认了操作")
        }))
        
        present(alert, animated: true)
    }
    
    @objc func showInputAlert() {
        var config = AlertConfig()
        config.style = .alert
        config.cornerRadius = 14
        
        let alert = LXAlertController(title: "操作确认",
                                      message: "您确定要进行此操作吗？此操作将不可恢复。",
                                      config: config)
        
        // 添加文本框
        alert.addTextField(placeholder: "输入操作说明")
        
        // 添加按钮 - 只有两个按钮时水平排列
        alert.addAction(LXAlertAction(title: "取消", style: .cancel))
        alert.addAction(LXAlertAction(title: "确认", style: .destructive, handler: {
            print("用户确认了操作")
        }))
        
        present(alert, animated: true)
    }
    
    @objc func showActionSheet() {
        var config = AlertConfig()
        config.style = .actionSheet
        config.animationType = .bottom
        
        let sheet = LXAlertController(title: "分享到",
                                      message: "请选择一个分享平台",
                                      config: config)
        
        // 添加多个选项
        let platforms = ["微信", "微博", "QQ", "钉钉", "短信", "邮件", "Facebook", "Twitter", "LinkedIn", "Facebook", "Twitter", "LinkedIn"]
        for platform in platforms {
            sheet.addAction(LXAlertAction(title: platform, handler: {
                print("分享到: \(platform)")
            }))
        }
        
        // 添加取消按钮 - 始终在底部
        sheet.addAction(LXAlertAction(title: "取消", style: .cancel))
        
        present(sheet, animated: true)
    }
}

extension ViewController {
    private func createCustomRatingView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let label = UILabel()
        label.text = "为此次服务评分:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        let ratingStack = UIStackView()
        ratingStack.axis = .horizontal
        ratingStack.distribution = .fillEqually
        ratingStack.spacing = 8
        
        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setTitle("\(i)", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 8
            ratingStack.addArrangedSubview(button)
        }
        
        container.addSubview(label)
        container.addSubview(ratingStack)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            ratingStack.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            ratingStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            ratingStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            ratingStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
}
