//
//  HomeNavBar.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/17.
//

import UIKit
import FirebaseAuth


class HomeNavBar: UIView {
    var repository: HomeViewRepository?
    
    let titleView = UIStackView()
    let buttonGroups = UIStackView()
    let profileButton = UIButton()
    let searchButton = UIButton()
    let title = UIImageView()
    let leftDrawerButton = UIButton()
    let blurEffect = UIBlurEffect(style: .regular)
    let container = UIVisualEffectView()
    let screenSize: CGRect = UIScreen.main.bounds
    
    weak var delegate: HomeViewController? {
        didSet {
            if let dele = delegate {
                searchButton.addTarget(dele, action: #selector(dele.searchButtonTouchUp), for: .touchUpInside)
                leftDrawerButton.addTarget(dele, action: #selector(dele.sideMenuButtonTouchUp), for: .touchUpInside)
                profileButton.addTarget(dele, action: #selector(dele.profileButtonTouchUp), for: .touchUpInside)
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        repository = HomeViewRepositoryImpl()
        initializeView()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        FirebaseAuth.Auth.auth().addStateDidChangeListener({ auth, user in
            if user == nil {
                self.profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
            }else{
                self.profileButton.setImage(UIImage(named: "sadfrog"), for: .normal)
            }
        })
        
        //self.backgroundColor = .blue
        self.translatesAutoresizingMaskIntoConstraints = false
        container.contentView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        buttonGroups.translatesAutoresizingMaskIntoConstraints = false
        leftDrawerButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        //UI configuration
        titleView.axis = .horizontal
        title.image = UIImage(named: "SomeLimeLogo")
        buttonGroups.distribution = .fill
        buttonGroups.axis = .horizontal
        buttonGroups.spacing = 10
        
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .label
        
        leftDrawerButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        leftDrawerButton.tintColor = .label
        
        container.effect = blurEffect
        
        profileButton.widthAnchor.constraint(equalToConstant: searchButton.intrinsicContentSize.width + 10).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: searchButton.intrinsicContentSize.height + 10).isActive = true
        profileButton.layer.cornerRadius = .greatestFiniteMagnitude
        
        self.addSubview(container)
        container.contentView.addSubview(titleView)
        container.contentView.addSubview(buttonGroups)
        container.contentView.addSubview(leftDrawerButton)
        buttonGroups.addArrangedSubview(searchButton)
        buttonGroups.addArrangedSubview(profileButton)
        titleView.addArrangedSubview(title)
        titleView.distribution = .fill
        titleView.spacing = 5
        
        
        
        
        NSLayoutConstraint.activate([
            leftDrawerButton.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 10),
            leftDrawerButton.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -10),
            buttonGroups.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -10),
            buttonGroups.centerYAnchor.constraint(equalTo: leftDrawerButton.centerYAnchor),
            titleView.centerXAnchor.constraint(equalTo: container.contentView.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: leftDrawerButton.centerYAnchor),
            title.heightAnchor.constraint(equalToConstant: 15),
            title.widthAnchor.constraint(equalToConstant: 100),
            container.heightAnchor.constraint(equalToConstant: screenSize.height * 0.12),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo:         container.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo:         container.contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo:         container.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo:         container.contentView.trailingAnchor)
        ])
    }
}
