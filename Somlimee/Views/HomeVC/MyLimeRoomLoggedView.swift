//
//  MyLimeRoomLoggedView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/31.
//

import UIKit

class MyLimeRoomLoggedView: UIView {
    
    
    //MARK: - Props
    
    private var repository: HomeViewRepository?
    
    var onClickMoreButton: ((String?)->Void)?
    
    var onClickPostCell: ((BoardPostMetaData)->Void)? {
        didSet{
            self.myLimeRoomBoardTable.onCellClicked = onClickPostCell
        }
    }
    
    // - 전체 컨테이너 (타이틀과 컨텐츠를 포함)
    let myLimeRoomContainer: UIStackView = UIStackView()
    
    let myLimeRoomTitle: UILabel = UILabel()
    
    private let myLimeRoomContentHStack: UIStackView = UIStackView()
    
    private let myLimeRoomImageContainer: UIView = UIView()
    
    private let myLimeRoomLimeImage: UIImageView = UIImageView()
    
    private let myLimeRoomBoardVStack: UIStackView = UIStackView()
    
    private let myLimeRoomBoardContentHStack: UIStackView = UIStackView()
    
    private let myLimeRoomBoardLabel: UILabel = UILabel()
    
    private let myLimeRoomBoardTextButton: UIButton = UIButton()
    
    private let myLimeRoomBoardTable: MyLimeRoomBoardTableView = MyLimeRoomBoardTableView()
    
    // - 데이터
    var boardName: String? {
        didSet{
            print(">>>> 나의 라임방 핫 게시물 읽어오는 중...")
                
            Task.init {
                do{
                    posts = try await self.repository?.getBoardHotPostsList(boardName: self.boardName ?? "NDD", startTime: "NaN", counts:4)
                } catch{
                    print(">>>> 핫 게시물 읽어오는 중에 에러가 발생했습니다:\n \(error)")
                }
            }
        }
    }
    private var posts: [BoardPostMetaData]? {
        didSet{
            print(">>>> 나의 라임방 포스트 뷰에 추가중...")
            print(">>>> \(posts?.description)")
            myLimeRoomBoardTable.data = posts
            print(">>>> 완료")
        }
    }
    @objc private func onTouchUpMoreButton(){
        print(">>>> \(boardName)으로 이동")
        onClickMoreButton?(boardName)
    }
    
    //MARK: - Props Configuration
    
    private func configure(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomContainer.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomContentHStack.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomLimeImage.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomImageContainer.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomBoardVStack.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomBoardLabel.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomBoardContentHStack.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomBoardTextButton.translatesAutoresizingMaskIntoConstraints = false
        myLimeRoomBoardTable.translatesAutoresizingMaskIntoConstraints = false
        
        
        myLimeRoomContainer.axis = .vertical
        myLimeRoomContainer.distribution = .fill
        myLimeRoomContainer.spacing = 17
        
        
        myLimeRoomContentHStack.axis = .horizontal
        myLimeRoomContentHStack.distribution = .fill
        myLimeRoomContentHStack.spacing = 40
        myLimeRoomContentHStack.alignment = .center
        
        
        myLimeRoomBoardVStack.axis = .vertical
        myLimeRoomBoardVStack.distribution = .equalCentering
        myLimeRoomBoardVStack.spacing = 5
        
        
        myLimeRoomBoardContentHStack.axis = .horizontal
        myLimeRoomBoardContentHStack.distribution = .fill
        myLimeRoomBoardContentHStack.spacing = 10
        
        myLimeRoomTitle.text = "나의 라임방"
        myLimeRoomTitle.font = .hanSansNeoBold(size: 21)
        myLimeRoomBoardLabel.text = "나의 라임방 핫! 게시물"
        myLimeRoomBoardLabel.font = .hanSansNeoBold(size: 15)
        myLimeRoomBoardTextButton.setAttributedTitle(NSAttributedString(AttributedString("더보기", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.hanSansNeoBold(size: 15)]))), for: .normal)
        myLimeRoomBoardTextButton.setTitleColor(.label, for: .normal)
        myLimeRoomBoardTextButton.addTarget(self, action: #selector(onTouchUpMoreButton), for: .touchUpInside)
        
        myLimeRoomImageContainer.layer.frame.size.height = 110
        myLimeRoomImageContainer.layer.frame.size.width = 110
        
        myLimeRoomLimeImage.image = UIImage(named: "limes")
        myLimeRoomLimeImage.contentMode = .scaleToFill
        myLimeRoomLimeImage.applyshadowWithCorner(containerView: myLimeRoomImageContainer, cornerRadious: 15)
        
        
    }
    internal func addSubviews(){
        
        self.addSubview(myLimeRoomContainer)
        myLimeRoomImageContainer.addSubview(myLimeRoomLimeImage)
        myLimeRoomContainer.addArrangedSubview(myLimeRoomTitle)
        myLimeRoomContainer.addArrangedSubview(myLimeRoomContentHStack)
        myLimeRoomContentHStack.addArrangedSubview(myLimeRoomImageContainer)
        myLimeRoomContentHStack.addArrangedSubview(myLimeRoomBoardVStack)
        myLimeRoomBoardVStack.addArrangedSubview(myLimeRoomBoardContentHStack)
        myLimeRoomBoardVStack.addArrangedSubview(myLimeRoomBoardTable)
        myLimeRoomBoardContentHStack.addArrangedSubview(myLimeRoomBoardLabel)
        myLimeRoomBoardContentHStack.addArrangedSubview(myLimeRoomBoardTextButton)
        
    }
    
    internal func layout(){
        
        NSLayoutConstraint.activate([
            myLimeRoomContainer.topAnchor.constraint(equalTo: self.topAnchor),
            myLimeRoomContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            myLimeRoomContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            myLimeRoomContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        NSLayoutConstraint.activate([
            myLimeRoomLimeImage.topAnchor.constraint(equalTo: myLimeRoomImageContainer.topAnchor),
            myLimeRoomLimeImage.bottomAnchor.constraint(equalTo: myLimeRoomImageContainer.bottomAnchor),
            myLimeRoomLimeImage.leadingAnchor.constraint(equalTo: myLimeRoomImageContainer.leadingAnchor),
            myLimeRoomLimeImage.trailingAnchor.constraint(equalTo: myLimeRoomImageContainer.trailingAnchor),
            
            myLimeRoomImageContainer.heightAnchor.constraint(equalToConstant: 110),
            myLimeRoomImageContainer.widthAnchor.constraint(equalToConstant: 110),
            
            myLimeRoomBoardTable.heightAnchor.constraint(equalToConstant: 70),
            
        ])
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        repository = HomeViewRepositoryImpl()
        initializeView()
        configure()
        addSubviews()
        layout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
