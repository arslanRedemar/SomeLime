//
//  BoardViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/04.
//

import UIKit
import FirebaseAuth
class BoardViewController: UIViewController {
    
    //MARK: - DATA
    var repository: BoardViewRepository?
    var boardName: String = "유머" {
        didSet{
            boardNavBar.title.text = boardName
            loadData()
        }
    }
    var info: BoardInfoData? {
        didSet{
            // should assign UI Label
            boardTapView.tapList = info?.tapList ?? []
            boardDescription.text = info?.boardDescription
            info?.boardLevel
            info?.boardHotKeyword
            boardTitle.text = info?.boardName
            info?.boardOwnerID
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    var posts: [BoardPostMetaData]? {
        didSet{
            // should assign data to the BoardTableView
            boardTableView.boardSectionPostCellData = posts
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    private var isLoading: Bool = false {
        didSet{
            if isLoading == false{
                spinner.isHidden = true
                spinner.stopAnimating()
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }else{
                spinner.isHidden = false
                spinner.startAnimating()
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    //MARK: - UI Components
    let contentScrollView: UIScrollView = UIScrollView()
    let boardTableView: BoardTableView = BoardTableView()
    let boardNavBar: BoardNavBar = BoardNavBar()
    let boardTapView: BoardTapView = BoardTapView()
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    let boardTitle: UILabel = UILabel()
    let boardDescription: UILabel = UILabel()
    let contents: UIStackView = UIStackView()
    
    
    @objc func handleRefreshControl() {
        // Update your content…
        loadData()
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.contentScrollView.refreshControl?.endRefreshing()
        }
    }
    private func transAuto(){
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        boardTableView.translatesAutoresizingMaskIntoConstraints = false
        boardNavBar.translatesAutoresizingMaskIntoConstraints = false
        boardTapView.translatesAutoresizingMaskIntoConstraints = false
        boardTitle.translatesAutoresizingMaskIntoConstraints = false
        boardDescription.translatesAutoresizingMaskIntoConstraints = false
        contents.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews(){
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contents)
        view.addSubview(boardTapView)
        view.addSubview(boardNavBar)
        contents.addArrangedSubview(boardTitle)
        contents.addArrangedSubview(boardDescription)
        contents.addArrangedSubview(boardTableView)
        contents.addArrangedSubview(spinner)
    }
    private func configure(){
        
        let refresh: UIRefreshControl = UIRefreshControl()
        self.contentScrollView.refreshControl = refresh
        self.contentScrollView.refreshControl?.addTarget(self, action:
                                                    #selector(handleRefreshControl),
                                                  for: .valueChanged)
        contentScrollView.delegate = self
        boardTableView.isScrollEnabled = false
        contents.axis = .vertical
        contents.distribution = .fill
        view.backgroundColor = .systemBackground
        contentScrollView.backgroundColor = .systemBackground
        boardTableView.didCellClicked = { str in
            // Should Navigate To PostVC
            let v = BoardPostViewController()
            v.boardName = self.boardName
            v.postId = str
            self.navigationController?.pushViewController(v, animated: true)
        }
        boardTapView.cellClicked = { str in
            // Should Filter Posts According to the taps
            let s: String = str ?? "Tap List Empty"
            print(s)
        }
        boardNavBar.onTouchUpBackButton = {
            self.navigationController?.popViewController(animated: true)
        }
        boardNavBar.onTouchUpProfileButton = {
            self.navigationController?.pushViewController(BoardPostWriteViewController(boardName: self.boardName), animated: true)
        }
        boardNavBar.dropDownTableClicked = { name in
            let boardV = BoardViewController()
            boardV.boardName = name
            boardV.boardNavBar.title.text = name
            self.boardNavBar.isDropDown = false
            var newList = self.navigationController?.viewControllers
            newList?.popLast()
            newList?.append(boardV)
            self.navigationController?.setViewControllers(newList ?? [boardV], animated: false)
        }
        boardTableView.boardSectionPostCellData = posts
        spinner.isHidden = true
        
    }
    
    
    private func layout(){
        NSLayoutConstraint.activate([
            boardTapView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.05),
            boardTapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            boardTapView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height*0.12)
        ])
        NSLayoutConstraint.activate([
            boardNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            boardNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boardNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.17),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            boardTitle.heightAnchor.constraint(equalToConstant: view.frame.height*0.05),
            boardDescription.heightAnchor.constraint(equalToConstant: view.frame.height*0.1)
        ])
        NSLayoutConstraint.activate([
            contents.widthAnchor.constraint(equalToConstant: view.frame.width),
            contents.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor),
            contents.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            contents.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            contents.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
        ])
    }
    private func loadData(){
        Task.init {
            do{
                self.info = try await repository?.getBoardInfoData(boardName: boardName)
                self.posts = try await repository?.getBoardPostMetaList(boardName: boardName, startTime: "NaN", counts: 4)
                //Relayout
            }catch{
                print(">>>> BOARD VIEW ERROR: Could Not Load Data - \(error)")
            }
        }
    }
    private func loadMorePosts(){
        isLoading = true
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
        isLoading = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repository = BoardViewRepositoryImpl()
        loadData()
        transAuto()
        addSubviews()
        configure()
        if FirebaseAuth.Auth.auth().currentUser == nil{
            boardNavBar.profileButton.isHidden = true
        }
        layout()
        
    }
    
}

extension BoardViewController: UIScrollViewDelegate{
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if isLoading{
//            return
//        }
//        if position > (boardTableView.contentSize.height - 100 - scrollView.frame.size.height) {
//
//            // reload and append data
//
//            print("Loading")
//            loadMorePosts()
//            print("Done!")
//        }
//    }
}


