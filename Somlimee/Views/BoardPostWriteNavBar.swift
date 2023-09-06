//
//  BoardPostWriteNavBar.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/04.
//

import UIKit

class BoardPostWriteNavBar: UIView {
    
    let titleView = UIStackView()
    let buttonGroups = UIStackView()
    let title = UILabel()
    let backButton = UIButton()
    let writeButton = UIButton()
    let blurEffect = UIBlurEffect(style: .regular)
    let container = UIVisualEffectView()
    let screenSize: CGRect = UIScreen.main.bounds
    var viewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var viewWidthConsstraint: NSLayoutConstraint = NSLayoutConstraint()
    var defaultMultiplierOfHeight: CGFloat = 0.12
    var onTouchUpBackButton: (()->Void)?
    var onTouchUpWriteButton: (()->Void)?
    
    @objc private func onTouchUpBack(){
        onTouchUpBackButton?()
    }
    @objc private func onTouchUpProfile(){
        onTouchUpWriteButton?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        
        
        
        
        //Auto layout pre-setup
        
        self.translatesAutoresizingMaskIntoConstraints = false
        container.contentView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        buttonGroups.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        writeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Data assignment
        viewWidthConsstraint = self.widthAnchor.constraint(equalToConstant: screenSize.width)
        viewHeightConstraint = self.heightAnchor.constraint(equalToConstant: screenSize.height * defaultMultiplierOfHeight)
        //UI configuration
        titleView.axis = .horizontal
        buttonGroups.distribution = .fill
        buttonGroups.axis = .horizontal
        buttonGroups.spacing = 10
        writeButton.setTitle("업로드", for: .normal)
        writeButton.setTitleColor(.label, for: .normal)
        writeButton.tintColor = .label
        writeButton.addTarget(self, action: #selector(onTouchUpProfile), for: .touchUpInside)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(onTouchUpBack), for: .touchUpInside)
        container.effect = blurEffect
        
        
        self.addSubview(container)
        container.contentView.addSubview(titleView)
        container.contentView.addSubview(buttonGroups)
        container.contentView.addSubview(backButton)
        buttonGroups.addArrangedSubview(writeButton)
        titleView.addArrangedSubview(title)
        titleView.distribution = .fill
        titleView.spacing = 5
        
        
        backButton.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 10).isActive = true
        backButton.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -10).isActive = true
        buttonGroups.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -10).isActive = true
        buttonGroups.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -10).isActive = true
        titleView.centerXAnchor.constraint(equalTo: container.contentView.centerXAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -10).isActive = true
        
        NSLayoutConstraint.activate([
            viewWidthConsstraint,
            viewHeightConstraint,
            self.topAnchor.constraint(equalTo: container.topAnchor),
            container.heightAnchor.constraint(equalToConstant: screenSize.height * defaultMultiplierOfHeight),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: container.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor)
        ])
        
    }
}


