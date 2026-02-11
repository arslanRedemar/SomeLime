//
//  MyLimeRoomView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/31.
//

import UIKit

class MyLimeRoomNotLoggedView: UIView {
    
    //MARK: - Props
    
    // - 전체 컨테이너 (타이틀과 컨텐츠를 포함)
    let myLimeRoomContainer: UIStackView = UIStackView()
    
    let myLimeRoomTitle: UILabel = UILabel()
    
    let myLimeRoomContentContainer: UIStackView = UIStackView()
    
    // - 로딩 뷰
    
    // - 비로그인 뷰
    private let myLimeRoomNotLoggedInMessage: UILabel = UILabel()
    
    private let myLimeRoomNotLoggedInMessageDetail: UILabel = UILabel()
    
    private let myLimeRoomNotLoggedInButton: UIButton = UIButton()
    
    // - 버튼 함수
    var logingInButton: ( () -> Void )?
    
    @objc private func loginButtonTouchedUp(){
        logingInButton?()
    }
    
    //MARK: - Props Configuration
    
    internal func configure(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomContainer.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomContentContainer.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomNotLoggedInMessage.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomNotLoggedInMessageDetail.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomNotLoggedInButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        myLimeRoomContainer.axis = .vertical
        myLimeRoomContainer.distribution = .fill
        myLimeRoomContainer.spacing = 17
        
        myLimeRoomContentContainer.axis = .vertical
        myLimeRoomContentContainer.distribution = .fill
        myLimeRoomContentContainer.spacing = 10
        myLimeRoomContentContainer.alignment = .center
        myLimeRoomContentContainer.layer.cornerRadius = 20
        myLimeRoomContentContainer.isLayoutMarginsRelativeArrangement = true
        myLimeRoomContentContainer.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
        myLimeRoomContentContainer.backgroundColor = SomLimeColors.systemGrayLight
        myLimeRoomTitle.text = "나의 라임방"
        myLimeRoomTitle.textColor = .label
        myLimeRoomTitle.font = UIFont.hanSansNeoBold(size: 21)
        
        myLimeRoomNotLoggedInMessage.text  = "앗! 로그인되지 않았습니다."
        myLimeRoomNotLoggedInMessage.textColor = .label
        myLimeRoomNotLoggedInMessage.font = UIFont.hanSansNeoBold(size: 14)
        
        myLimeRoomNotLoggedInMessageDetail.text  = "로그인해서 나만의 라임방을 찾아보세요!"
        myLimeRoomNotLoggedInMessageDetail.textColor = .label
        myLimeRoomNotLoggedInMessageDetail.font = UIFont.hanSansNeoRegular(size: 14)
        
        var filled = UIButton.Configuration.filled()
        filled.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)
        filled.baseForegroundColor = .label
        filled.baseBackgroundColor = SomLimeColors.primaryColor
        filled.cornerStyle = .capsule
        filled.attributedTitle = AttributedString("로그인 하러가기", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.hanSansNeoMedium(size: 16)]))
        myLimeRoomNotLoggedInButton.configuration = filled
        myLimeRoomNotLoggedInButton.addTarget(self, action: #selector(loginButtonTouchedUp), for: .touchUpInside)
        
    }
    internal func addSubviews(){
        
        self.addSubview(myLimeRoomContainer)
        
        myLimeRoomContainer.addArrangedSubview(myLimeRoomTitle)
        myLimeRoomContainer.addArrangedSubview(myLimeRoomContentContainer)
        myLimeRoomContentContainer.addArrangedSubview(myLimeRoomNotLoggedInMessage)
        myLimeRoomContentContainer.addArrangedSubview(myLimeRoomNotLoggedInMessageDetail)
        myLimeRoomContentContainer.addArrangedSubview(myLimeRoomNotLoggedInButton)
        
    }
    
    internal func layout(){
        
        NSLayoutConstraint.activate([
            myLimeRoomContainer.topAnchor.constraint(equalTo: self.topAnchor),
            myLimeRoomContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            myLimeRoomContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            myLimeRoomContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
        ])
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
        configure()
        addSubviews()
        layout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

