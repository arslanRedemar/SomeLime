//
//  HomeBoardTableView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/19.
//

import UIKit

class HomeBoardTableView: UITableView{
    
    //fixtures
    
    private var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    private let topBottomInsets: CGFloat = 10
    var boardSectionPostCellData: [BoardPostMetaData]?{
        didSet{
            self.reloadData()
        }
    }
    
    
    var didCellClicked: ((String)->Void)?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
        
        dataSource = self
        
        self.isScrollEnabled = false
        
        self.register(HomeBoardTableViewCell.self, forCellReuseIdentifier: String(describing: HomeBoardTableViewCell.self))
        
        let label = UILabel()
        label.text = "H"
        let image = UIImageView(image: UIImage(systemName: "person.fill"))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension HomeBoardTableView: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boardSectionPostCellData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: String(describing: HomeBoardTableViewCell.self), for: indexPath) as! HomeBoardTableViewCell
        cell.postTitle = boardSectionPostCellData?[indexPath.item].postTitle ?? ""
        cell.postType = boardSectionPostCellData?[indexPath.item].postType ?? PostType.text
        cell.numberOfViews = boardSectionPostCellData?[indexPath.item].numberOfViews ?? 0
        cell.numberOfRecommendation = boardSectionPostCellData?[indexPath.item].numberOfVoteUps ?? 0
        
        Task.init {
            do{
                let userName = try await userNameParser(uid: boardSectionPostCellData?[indexPath.item].userID ?? "")
                cell.userID = userName ?? "ERROR"
            }catch{
                cell.userID = "ERROR: \(error)"
            }
        }
        cell.publishedTime = boardSectionPostCellData?[indexPath.item].publishedTime ?? ""
        cell.boardCategory = boardSectionPostCellData?[indexPath.item].boardTap ?? ""
        cell.boardID = boardSectionPostCellData?[indexPath.item].boardID ?? ""
        cell.postID = boardSectionPostCellData?[indexPath.item].postID ?? ""
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cellForRow(at: indexPath) as! HomeBoardTableViewCell
        didCellClicked?(cell.postID ?? "")
    }
    
    
    
}
class HomeBoardTableViewCell: UITableViewCell{
    
    private let container: UIView = UIView()
    private let postTypeImage: UIImageView = UIImageView()
    private let postLabel: UILabel = UILabel()
    private let postTimeLabel: UILabel = UILabel()
    private let boardCategoryLabel: UILabel = UILabel()
    private let userImage: UIImageView = UIImageView()
    private let userIDLabel: UILabel = UILabel()
    private let numberOfViewsLabel: UILabel = UILabel()
    private let recommendationLabel: UILabel = UILabel()
    private let sideInsets: CGFloat = 10
    private let spaceInCell: CGFloat = 6
    
    public var publishedTime: String = ""{
        didSet{
            let timeString = publishedTime
//            let startIndex = timeString.index(timeString.startIndex, offsetBy: 11)
//            let endIndex = timeString.index(timeString.startIndex, offsetBy: 15)
//            let subString = String(timeString[startIndex...endIndex])
            postTimeLabel.text = timeString
                
        }
    }
    
    public var postType: PostType = .text {
        didSet{
            switch (postType){
            case .text:
                postTypeImage.image = UIImage(systemName: "t.square")
            case .image:
                postTypeImage.image = UIImage(systemName: "photo.fill")
            case .video:
                postTypeImage.image = UIImage(systemName: "video.fill")
            }
        }
    }
    
    public var postTitle: String = "postitle" {
        didSet{
            postLabel.text = postTitle
        }
    }
    
    public var boardCategory: String = "Category" {
        didSet{
            boardCategoryLabel.text = boardCategory
        }
    }
    
    public var userID: String = "userid"{
        didSet{
            userIDLabel.text = userID
        }
    }
    
    public var numberOfViews: Int = 10 {
        didSet{
            numberOfViewsLabel.text = "조회 \(numberOfViews)"
        }
    }
    
    public var numberOfRecommendation: Int = 10 {
        didSet{
            recommendationLabel.text = "추천 \(numberOfRecommendation)"
        }
    }
    public var boardID: String?
    public var postID: String?
    
    private func configure(){
        
        container.translatesAutoresizingMaskIntoConstraints = false
        postTypeImage.translatesAutoresizingMaskIntoConstraints = false
        postLabel.translatesAutoresizingMaskIntoConstraints = false
        postTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        boardCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        userIDLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfViewsLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Adding Subviews
        self.addSubview(container)
        container.addSubview(postTypeImage)
        container.addSubview(postLabel)
        container.addSubview(postTimeLabel)
        container.addSubview(boardCategoryLabel)
        container.addSubview(userImage)
        container.addSubview(userIDLabel)
        container.addSubview(numberOfViewsLabel)
        container.addSubview(recommendationLabel)
        
        
        
        //postTypeImage
        postTypeImage.image = UIImage(systemName: "person.fill")
        //postLabel
        
        //postTimeLabel
        
        //boardCategoryTapListView
        
        //userImage
        
        //userIDLabel
        
        //numberOfViewsLabel
        
        //recommendationLabel
        
    }
    private func layout(){
        
        
        //container
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        //postTypeImage
        NSLayoutConstraint.activate([
            postTypeImage.topAnchor.constraint(equalTo: container.topAnchor, constant: spaceInCell),
            postTypeImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: sideInsets),
        ])
        //postLabel
        NSLayoutConstraint.activate([
            postLabel.topAnchor.constraint(equalTo: postTypeImage.topAnchor),
            postLabel.leadingAnchor.constraint(equalTo: postTypeImage.trailingAnchor, constant: sideInsets),
        ])
        //postTimeLabel
        NSLayoutConstraint.activate([
            postTimeLabel.topAnchor.constraint(equalTo: postTypeImage.topAnchor),
            postTimeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -sideInsets),
        ])
        //boardCategoryLabel
        NSLayoutConstraint.activate([
            boardCategoryLabel.topAnchor.constraint(equalTo: postTypeImage.bottomAnchor),
            boardCategoryLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -sideInsets),
        ])
        
        //userImage
        NSLayoutConstraint.activate([
            userImage.topAnchor.constraint(equalTo: postTypeImage.bottomAnchor),
            userImage.leadingAnchor.constraint(equalTo: postTypeImage.leadingAnchor),
        ])
        //userIDLabel
        NSLayoutConstraint.activate([
            userIDLabel.topAnchor.constraint(equalTo: postTypeImage.bottomAnchor),
            userIDLabel.leadingAnchor.constraint(equalTo: userImage.trailingAnchor,constant: spaceInCell),
        ])
        //numberOfViewsLabel
        NSLayoutConstraint.activate([
            numberOfViewsLabel.topAnchor.constraint(equalTo: postTypeImage.bottomAnchor),
            numberOfViewsLabel.leadingAnchor.constraint(equalTo: userIDLabel.trailingAnchor,constant: spaceInCell),
        ])
        //recommendationLabel
        NSLayoutConstraint.activate([
            recommendationLabel.topAnchor.constraint(equalTo: postTypeImage.bottomAnchor),
            recommendationLabel.leadingAnchor.constraint(equalTo: numberOfViewsLabel.trailingAnchor,constant: spaceInCell),
        ])
        
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeView()
        configure()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
