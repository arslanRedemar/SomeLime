//
//  ProfileCardView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/08/07.
//

import UIKit

class ProfileCardView: UIView {
    
    var data: ProfileData? {
        didSet{
            
            userNameLabel.text = data?.userName
            dateDetailLabel.text = data?.signUpDate
            pointDetailLabel.text = String(data?.points ?? 0)
            
            postsNum.text = String(data?.numOfPosts ?? 0)
            totalLikesNum.text = String(data?.totalUps ?? 0)
            givenLikesNum.text = String(data?.receivedUps ?? 0)
            daysOfActiveNum.text = String(data?.daysOfActive ?? 0)
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    //UI Components Declaration
    
    let cardContainerVStack: UIStackView = UIStackView()
    
    let firstLineHStack: UIStackView = UIStackView()
    
    let secondLineVStack: UIStackView = UIStackView()
    
    let firstLineRightContainer: UIStackView = UIStackView()
    
    let userProfileImage: UIImageView = UIImageView()
    
    
    let nameContainer: UIStackView = UIStackView()
    
    let userNameLabel: UILabel = UILabel()
    
    let userNameLabelRight: UILabel = UILabel()
    
    
    let dateContainer: UIStackView = UIStackView()
    
    let dateLabel: UILabel = UILabel()
    
    let dateDetailLabel: UILabel = UILabel()
    
    let secondLinePointContainer: UIStackView = UIStackView()
    
    let pointContainer: UIStackView = UIStackView()
    
    let pointLabel: UILabel = UILabel()
    
    let pointDetailLabel: UILabel = UILabel()
    
    
    let profLabelsHStack: UIStackView = UIStackView()
    
    let postLabel: UILabel = UILabel()
    let totalLikesLabel: UILabel = UILabel()
    let givenLikesLabel: UILabel = UILabel()
    let countOfActiveLabel: UILabel = UILabel()
    
    let profDataHStack: UIStackView = UIStackView()
    
    let verticalLine1: UIView = UIView()
    let verticalLine2: UIView = UIView()
    let verticalLine3: UIView = UIView()
    let postsNum: UILabel = UILabel()
    let totalLikesNum: UILabel = UILabel()
    let givenLikesNum: UILabel = UILabel()
    let daysOfActiveNum: UILabel = UILabel()
    
    private func trans(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        cardContainerVStack.translatesAutoresizingMaskIntoConstraints = false
        firstLineHStack.translatesAutoresizingMaskIntoConstraints = false
        secondLineVStack.translatesAutoresizingMaskIntoConstraints = false
        firstLineRightContainer.translatesAutoresizingMaskIntoConstraints = false
        userProfileImage.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabelRight.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        pointContainer.translatesAutoresizingMaskIntoConstraints = false
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        pointDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        postLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLikesLabel.translatesAutoresizingMaskIntoConstraints = false
        givenLikesLabel.translatesAutoresizingMaskIntoConstraints = false
        countOfActiveLabel.translatesAutoresizingMaskIntoConstraints = false
        profDataHStack.translatesAutoresizingMaskIntoConstraints = false
        profLabelsHStack.translatesAutoresizingMaskIntoConstraints = false
        postsNum.translatesAutoresizingMaskIntoConstraints = false
        totalLikesNum.translatesAutoresizingMaskIntoConstraints = false
        givenLikesNum.translatesAutoresizingMaskIntoConstraints = false
        daysOfActiveNum.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func setup(){
        
        backgroundColor = SomLimeColors.primaryColor
        layer.cornerRadius = 20
        
        cardContainerVStack.axis = .vertical
        cardContainerVStack.distribution = .fill
        cardContainerVStack.spacing = 10
        cardContainerVStack.alignment = .leading
        cardContainerVStack.addArrangedSubview(firstLineHStack)
        cardContainerVStack.addArrangedSubview(secondLineVStack)
        
        firstLineHStack.axis = .horizontal
        firstLineHStack.distribution = .fill
        firstLineHStack.spacing = 10
        firstLineHStack.alignment = .leading
        firstLineHStack.addArrangedSubview(userProfileImage)
        firstLineHStack.addArrangedSubview(firstLineRightContainer)
        
        secondLineVStack.axis = .vertical
        secondLineVStack.distribution = .fill
        secondLineVStack.spacing = 3
        secondLineVStack.alignment = .leading
        secondLineVStack.addArrangedSubview(profLabelsHStack)
        secondLineVStack.addArrangedSubview(profDataHStack)
        
        firstLineRightContainer.axis = .vertical
        firstLineRightContainer.distribution = .fill
        firstLineRightContainer.spacing = 10
        firstLineRightContainer.alignment = .leading
        firstLineRightContainer.addArrangedSubview(nameContainer)
        firstLineRightContainer.addArrangedSubview(dateContainer)
        firstLineRightContainer.addArrangedSubview(pointContainer)
        
        userProfileImage.layer.cornerRadius = .greatestFiniteMagnitude
        userProfileImage.image = UIImage(named: "sadfrog")
        
        nameContainer.axis = .horizontal
        nameContainer.distribution = .fill
        nameContainer.spacing = 10
        nameContainer.alignment = .center
        nameContainer.addArrangedSubview(userNameLabel)
        nameContainer.addArrangedSubview(userNameLabelRight)
        
        userNameLabel.font = .hanSansNeoMedium(size: 21)
        userNameLabel.textColor = SomLimeColors.darkPrimaryColor
        userNameLabelRight.font = .hanSansNeoRegular(size: 16)
        userNameLabelRight.textColor = .white
        userNameLabelRight.text = "님"
        
        dateContainer.axis = .horizontal
        dateContainer.distribution = .fill
        dateContainer.spacing = 10
        dateContainer.alignment = .leading
        dateContainer.addArrangedSubview(dateLabel)
        dateContainer.addArrangedSubview(dateDetailLabel)
        
        
        
        dateLabel.font = .hanSansNeoBold(size: 11)
        dateLabel.textColor = .white
        dateLabel.text = "가입일"
        dateDetailLabel.font = .hanSansNeoRegular(size: 11)
        dateDetailLabel.textColor = .white
        
        
        pointContainer.axis = .horizontal
        pointContainer.distribution = .fill
        pointContainer.spacing = 10
        pointContainer.alignment = .leading
        pointContainer.addArrangedSubview(pointLabel)
        pointContainer.addArrangedSubview(pointDetailLabel)
        
        pointLabel.font = .hanSansNeoBold(size: 11)
        pointLabel.textColor = .white
        pointLabel.text = "포인트"
        pointDetailLabel.font = .hanSansNeoRegular(size: 11)
        pointDetailLabel.textColor = .white
        
        secondLinePointContainer.axis = .horizontal
        secondLinePointContainer.distribution = .fill
        secondLinePointContainer.spacing = 10
        secondLinePointContainer.alignment = .center
        secondLinePointContainer.addArrangedSubview(postLabel)
        secondLinePointContainer.addArrangedSubview(totalLikesLabel)
        secondLinePointContainer.addArrangedSubview(givenLikesLabel)
        secondLinePointContainer.addArrangedSubview(countOfActiveLabel)
        
        pointContainer.addArrangedSubview(daysOfActiveNum)
        postLabel.font = .hanSansNeoBold(size: 12)
        postLabel.textColor = .white
        postLabel.text = "게시글 수"
        postLabel.textAlignment = .center
        
        totalLikesLabel.font = .hanSansNeoBold(size: 12)
        totalLikesLabel.textColor = .white
        totalLikesLabel.text = "준 추천수"
        totalLikesLabel.textAlignment = .center
        
        givenLikesLabel.font = .hanSansNeoBold(size: 12)
        givenLikesLabel.textColor = .white
        givenLikesLabel.text = "받은 추천수"
        givenLikesLabel.textAlignment = .center
        
        countOfActiveLabel.font = .hanSansNeoBold(size: 12)
        countOfActiveLabel.textColor = .white
        countOfActiveLabel.text = "활동일수"
        countOfActiveLabel.textAlignment = .center
        
        
        profDataHStack.axis = .horizontal
        profDataHStack.distribution = .equalSpacing
        profDataHStack.spacing = 10
        profDataHStack.alignment = .center
        profDataHStack.addArrangedSubview(postsNum)
        profDataHStack.addArrangedSubview(verticalLine1)
        profDataHStack.addArrangedSubview(totalLikesNum)
        profDataHStack.addArrangedSubview(verticalLine2)
        profDataHStack.addArrangedSubview(givenLikesNum)
        profDataHStack.addArrangedSubview(verticalLine3)
        profDataHStack.addArrangedSubview(daysOfActiveNum)
        
        profLabelsHStack.axis = .horizontal
        profLabelsHStack.distribution = .equalSpacing
        profLabelsHStack.spacing = 10
        profLabelsHStack.alignment = .leading
        profLabelsHStack.addArrangedSubview(postLabel)
        profLabelsHStack.addArrangedSubview(totalLikesLabel)
        profLabelsHStack.addArrangedSubview(givenLikesLabel)
        profLabelsHStack.addArrangedSubview(countOfActiveLabel)
        
        postsNum.font = .hanSansNeoMedium(size: 14)
        postsNum.textColor = .white
        postsNum.textAlignment = .center
        
        totalLikesNum.font = .hanSansNeoMedium(size: 14)
        totalLikesNum.textColor = .white
        totalLikesNum.textAlignment = .center
        
        givenLikesNum.font = .hanSansNeoMedium(size: 14)
        givenLikesNum.textColor = .white
        givenLikesNum.textAlignment = .center
        
        daysOfActiveNum.font = .hanSansNeoMedium(size: 14)
        daysOfActiveNum.textColor = .white
        daysOfActiveNum.textAlignment = .center
        
        verticalLine1.backgroundColor = SomLimeColors.lightPrimaryColor
        verticalLine2.backgroundColor = SomLimeColors.lightPrimaryColor
        verticalLine3.backgroundColor = SomLimeColors.lightPrimaryColor
        
    }
    private func layout(){
        addSubview(cardContainerVStack)
        NSLayoutConstraint.activate([
            cardContainerVStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cardContainerVStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            cardContainerVStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardContainerVStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            userProfileImage.widthAnchor.constraint(equalToConstant: 75),
            userProfileImage.heightAnchor.constraint(equalToConstant: 75),
            
            postLabel.centerXAnchor.constraint(equalTo: postsNum.centerXAnchor),
            totalLikesLabel.centerXAnchor.constraint(equalTo: totalLikesNum.centerXAnchor),
            givenLikesLabel.centerXAnchor.constraint(equalTo: givenLikesNum.centerXAnchor),
            countOfActiveLabel.centerXAnchor.constraint(equalTo: daysOfActiveNum.centerXAnchor),
            
            verticalLine1.widthAnchor.constraint(equalToConstant: 2),
            verticalLine2.widthAnchor.constraint(equalToConstant: 2),
            verticalLine3.widthAnchor.constraint(equalToConstant: 2),
            verticalLine1.heightAnchor.constraint(equalTo: profDataHStack.heightAnchor),
            verticalLine2.heightAnchor.constraint(equalTo: profDataHStack.heightAnchor),
            verticalLine3.heightAnchor.constraint(equalTo: profDataHStack.heightAnchor),
            
            firstLineHStack.widthAnchor.constraint(equalTo: cardContainerVStack.widthAnchor),
            secondLineVStack.widthAnchor.constraint(equalTo: firstLineHStack.widthAnchor),
            profDataHStack.widthAnchor.constraint(equalTo: secondLineVStack.widthAnchor),
            profLabelsHStack.widthAnchor.constraint(equalTo: secondLineVStack.widthAnchor),
            profDataHStack.heightAnchor.constraint(equalTo: profLabelsHStack.heightAnchor, multiplier: 2.0)
        ])
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        trans()
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
