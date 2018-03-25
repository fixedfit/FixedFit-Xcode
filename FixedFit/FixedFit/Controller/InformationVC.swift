//
//  InformationVC.swift
//  Liberty Motor Freight
//
//  Created by Amanuel Ketebo on 9/14/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

struct ButtonData {
    let title: String
    let color: UIColor
    let action: (() -> Void)?
}

class InformationVC: UIViewController {
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    private var image: UIImage?
    private var message: String!
    private var subtitleMessage: String!
    private var leftButtonData: ButtonData?
    private var rightButtonData: ButtonData?
    
    init(message: String, image: UIImage?, leftButtonData: ButtonData?, rightButtonData: ButtonData?) {
        super.init(nibName: "InformationVC", bundle: nil)
        self.message = message
        self.image = image
        self.leftButtonData = leftButtonData
        self.rightButtonData = rightButtonData
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    init(message: String, subtitle: String, image: UIImage?, leftButtonData: ButtonData?, rightButtonData: ButtonData?) {
        super.init(nibName: "InformationVC", bundle: nil)
        self.message = message
        self.subtitleMessage = subtitle
        self.image = image
        self.leftButtonData = leftButtonData
        self.rightButtonData = rightButtonData
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        messageLabel.text = message
        subtitleLabel.text = subtitleMessage
        imageView.image = image
        setupStackView()
    }
    
    private func setupStackView() {
        if leftButtonData == nil && rightButtonData == nil {
            seperatorView.removeFromSuperview()
            buttonStackView.removeFromSuperview()
            subtitleLabel.bottomAnchor.constraint(equalTo: informationView.bottomAnchor, constant: -30).isActive = true
            
            return
        }

        var buttons: [UIView] = []
        let buttonFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        
        if let leftButtonData = leftButtonData {
            let leftButton = UIButton(type: .system)
            leftButton.setTitle(leftButtonData.title, for: .normal)
            leftButton.setTitleColor(leftButtonData.color, for: .normal)
            leftButton.titleLabel?.font = buttonFont
            leftButton.addTarget(self, action: #selector(touchedLeftButton), for: .touchUpInside)
            buttons.append(leftButton)
        }
        
        if let rightButtonData = rightButtonData {
            let rightButton = UIButton(type: .system)
            rightButton.setTitle(rightButtonData.title, for: .normal)
            rightButton.setTitleColor(rightButtonData.color, for: .normal)
            rightButton.titleLabel?.font = buttonFont
            rightButton.addTarget(self, action: #selector(touchedRightButton), for: .touchUpInside)
            buttons.append(rightButton)
        }
        
        buttons.forEach { (view) in
            buttonStackView.addArrangedSubview(view)
        }
    }
    
    @objc private func touchedLeftButton() {
        dismiss(animated: true, completion: leftButtonData?.action)
    }
    
    @objc private func touchedRightButton() {
        dismiss(animated: true, completion: rightButtonData?.action)
    }
    
    deinit {
        print("InformationVC has been deallocated :)")
    }
}
