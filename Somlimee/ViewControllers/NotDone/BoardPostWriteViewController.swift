//
//  BoardPostWriteViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/04.
//

import UIKit
import FirebaseAuth
class BoardPostWriteViewController: UIViewController {
    var boardName: String
    private var pickedTap: String?
//    var repository: BoardViewRepository? {
//        didSet{
//            loadData()
//            view.setNeedsLayout()
//            view.layoutIfNeeded()
//        }
//    }
    let navBar: BoardPostWriteNavBar = BoardPostWriteNavBar()
    let boardTapView: BoardTapView = BoardTapView()
    let titleView: UITextField = UITextField()
    let contentView: UITextView = UITextView()
    
    private func loadData(){
        Task.init {
//            boardTapView.tapList = try await repository?.getBoardInfoData(boardName: boardName)?.tapList ?? []
//            guard let elems = boardTapView.tapList else {
//                return
//            }
//            pickedTap = elems[0]
            
        }
    }
    private func transAutoMask(){
        navBar.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        boardTapView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func addSubviews(){
        view.addSubview(titleView)
        view.addSubview(boardTapView)
        view.addSubview(contentView)
        view.addSubview(navBar)
    }
    private func configureUIComponents(){
        view.backgroundColor = .systemBackground
        navBar.title.text = boardName
        titleView.backgroundColor = .gray
        titleView.placeholder = "제목..."
        contentView.textAlignment = .left
        navBar.onTouchUpWriteButton = {
            print(">>>> 업로드 중")
            Task.init {
                do{
                    guard let user = FirebaseAuth.Auth.auth().currentUser else{
                        throw UserLoginFailures.LoginFailed
                    }
                    
                    let post = BoardPostContentData(boardPostTap: self.pickedTap ?? "", boardPostUserId: user.uid, boardPostTitle: self.titleView.text ?? "", boardPostParagraph: self.contentView.text ?? "", boardPostImages: [], boardPostComments: [])
                    
                    print(">>>> 포스트 오브젝트 생성... \n\t상세설명: \n\tUser ID -> \(post.boardPostUserId)\n\tBoard Post Title -> \(post.boardPostTitle)\n\tBoard Tap List -> \(post.boardPostTap)\n\tBoard Post Paragraph -> \(post.boardPostParagraph)\n\tBoard Post Image URLs -> \(post.boardPostImages)")
                    
                    //try await self.repository?.writeBoardPost(boardName: self.boardName, postData:   post)
                    
                    print(">>>> 업로드 성공")
                }catch{
                    print(">>>> 업로드 실패: \(error)")
                }
            }
            //navigate to the BoardView
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.viewControllers.last?.view.setNeedsLayout()
        }
        navBar.onTouchUpBackButton = {
            self.navigationController?.popViewController(animated: true)
        }
        boardTapView.cellClicked = { tap in
            self.pickedTap = tap
        }
    }
    private func layout(){
        
        NSLayoutConstraint.activate([
            
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            
            boardTapView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 10),
            boardTapView.heightAnchor.constraint(equalToConstant: 0.05 * view.frame.height),
            boardTapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boardTapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            
            titleView.topAnchor.constraint(equalTo: boardTapView.bottomAnchor, constant: 10),
            titleView.heightAnchor.constraint(equalToConstant: 0.05 * view.frame.height),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            
            contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 15),
            contentView.heightAnchor.constraint(equalToConstant: 0.4 * view.frame.height),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    
    
    init(boardName: String) {
        //self.repository = BoardViewRepositoryImpl()
        self.boardName = boardName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
        transAutoMask()
        addSubviews()
        configureUIComponents()
        layout()
    }
    
    
}
