//
//  BoardViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/04.
//

import UIKit
import FirebaseAuth

class LimeRoomViewController: UIViewController {
    
    //MARK: - DATA
    //var repository: BoardViewRepository?
    
    var viewModel: LimeRoomViewModel?
    
    var boardName: String = "유머" {
        didSet{
            limeRoomNavBar.title.text = boardName
            loadData()
        }
    }
    
    var info: LimeRoomMeta? {
        didSet{
            // should assign UI Label
            tabView.tapList = info?.limeRoomTabs ?? []
            roomDesc.text = info?.limeRoomDescription
            roomTitle.text = info?.limeRoomName
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    var posts: LimeRoomPostList? {
        didSet{
            // should assign data to the BoardTableView
            postListView.postItem = posts
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    
    var fogTouched: (()->())?
    
    
    let fogView: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = .black
        view.layer.opacity = 0.3
        return view
    }()
    
    
    
    //MARK: - UI Components
    let contentScrollView: UIScrollView = UIScrollView()
    let postListView: LimeRoomPostListView = LimeRoomPostListView()
    let limeRoomNavBar: LimeRoomNavBar = LimeRoomNavBar()
    let tabView: BoardTapView = BoardTapView()
    let writePostButton: UIButton = UIButton()
    let roomTitle: UILabel = UILabel()
    let roomDesc: UILabel = UILabel()
    let contents: UIStackView = UIStackView()
    
    @objc func handleRefreshControl() {
        // Update your content…
        loadData()
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.contentScrollView.refreshControl?.endRefreshing()
        }
    }
    @objc func writeButtonClicked() {
        let postVC = BoardPostWriteViewController(boardName: boardName)
        navigationController?.pushViewController(postVC, animated: true)
    }
    private func transAuto(){
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        postListView.translatesAutoresizingMaskIntoConstraints = false
        limeRoomNavBar.translatesAutoresizingMaskIntoConstraints = false
        tabView.translatesAutoresizingMaskIntoConstraints = false
        roomTitle.translatesAutoresizingMaskIntoConstraints = false
        writePostButton.translatesAutoresizingMaskIntoConstraints = false
        roomDesc.translatesAutoresizingMaskIntoConstraints = false
        contents.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews(){
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contents)
        view.addSubview(tabView)
        view.addSubview(limeRoomNavBar)
        view.addSubview(writePostButton)
        contents.addArrangedSubview(roomTitle)
        contents.addArrangedSubview(roomDesc)
        contents.addArrangedSubview(postListView)
    }
    private func configure(){
        
        let refresh: UIRefreshControl = UIRefreshControl()
        self.contentScrollView.refreshControl = refresh
        self.contentScrollView.refreshControl?.addTarget(self, action:
                                                            #selector(handleRefreshControl),
                                                         for: .valueChanged)
        
        postListView.isScrollEnabled = false
        contents.axis = .vertical
        contents.distribution = .fill
        view.backgroundColor = .systemBackground
        contentScrollView.backgroundColor = .systemBackground
        
        writePostButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
        writePostButton.setTitleColor(SomLimeColors.labelLight, for: .normal)
        writePostButton.backgroundColor = SomLimeColors.primaryColor
        writePostButton.layer.cornerRadius = 5
        writePostButton.setTitle("글쓰기", for: .normal)
        postListView.didCellClicked = { str in
            // Should Navigate To PostVC
            let v = BoardPostViewController()
            v.boardName = self.boardName
            v.postId = str
            self.navigationController?.pushViewController(v, animated: true)
        }
        tabView.cellClicked = { str in
            // Should Filter Posts According to the taps
            let s: String = str ?? "Tap List Empty"
            print(s)
        }
        limeRoomNavBar.backButtonTouchUpFunc = {
            self.navigationController?.popViewController(animated: true)
        }
        limeRoomNavBar.profileButtonTouchUpFunc = {
            self.navigationController?.pushViewController(BoardPostWriteViewController(boardName: self.boardName), animated: true)
        }
        
        postListView.postItem = posts
        
    }
    
    
    private func layout(){
        NSLayoutConstraint.activate([
            tabView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.05),
            tabView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            tabView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height*0.12),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            limeRoomNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            limeRoomNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            limeRoomNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.17),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            roomTitle.heightAnchor.constraint(equalToConstant: view.frame.height*0.05),
            roomDesc.heightAnchor.constraint(equalToConstant: view.frame.height*0.1)
        ])
        NSLayoutConstraint.activate([
            contents.widthAnchor.constraint(equalToConstant: view.frame.width),
            contents.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor),
            contents.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            contents.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            contents.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            writePostButton.heightAnchor.constraint(equalToConstant: view.frame.height * 0.03),
            writePostButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            writePostButton.leadingAnchor.constraint(equalTo: tabView.trailingAnchor, constant: 10),
            writePostButton.centerYAnchor.constraint(equalTo: tabView.centerYAnchor),
        ])
    }
    private func loadData(){
        Task.init {
            do{
                self.info = try await viewModel?.getLimeRoomMetaInfo(boardName: boardName)
            }catch{
                print(">>>> BOARD VIEW ERROR: Could Not Load Data - \(error)")
            }
        }
        Task.init {
            do{
                self.posts = try await viewModel?.getLimeRoomPostList(boardName: boardName)
            }catch{
                print(">>>> BOARD VIEW ERROR: Could Not Load Data - \(error)")
            }
        }
    }
    private func loadMorePosts(){
        
        Task.init {
            do{
                guard let last = self.posts?.last else{
                    guard let temp = try await repository?.getBoardPostMetaList(boardName: boardName, startTime: "NaN", counts: 4)
                    else{
                        return
                    }
                    for post in temp{
                        self.posts?.append(post)
                    }
                    return
                }
                guard let temp = try await repository?.getBoardPostMetaList(boardName: boardName, startTime: last.publishedTime, counts: 4)
                else{
                    return
                }
                for post in temp{
                    self.posts?.append(post)
                }
            }catch{
                
                print(">>>> GET BOARD POSTS ERROR: Could Not Load More Data - \(error)")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AppDelegate.container.resolve(LimeRoomViewModel.self)
        
        loadData()
        transAuto()
        addSubviews()
        configure()
        if FirebaseAuth.Auth.auth().currentUser == nil{
            limeRoomNavBar.profileButton.isHidden = true
        }
        layout()
        
    }
    
}


