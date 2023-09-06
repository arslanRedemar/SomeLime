//
//  HomeViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/24.
//

import UIKit
import FirebaseAuth

fileprivate enum HomeViewStaticData {
    
    
}

class HomeViewController: UIViewController {
    
    //Base
    var repository: HomeViewRepository?
    
    let navBar: HomeNavBar = HomeNavBar()
    
    let scrollView: UIScrollView = UIScrollView()
    
    let contentView: UIStackView = UIStackView()
    
    //MyLimeVIew
    let myLimeRoomNotLoggedView: MyLimeRoomNotLoggedView = MyLimeRoomNotLoggedView()
    
    let myLimeRoomLoggedView: MyLimeRoomLoggedView = MyLimeRoomLoggedView()
    
    //Other Lime Rooms
    let otherLimeRoomScrollView: OtherLimeRoomsScrollView = OtherLimeRoomsScrollView()
    
    //Lime Trends
    let limeTrendCollectionView: LimeTrendCollectionView = LimeTrendCollectionView()
    
    let limesToday: LimesTodayView = LimesTodayView()
    
    let limeTest: LimeTestSectionView = LimeTestSectionView()
    
    var myRoomName: String = "유머"
    
    var scrollViewTopConstraint: NSLayoutConstraint?
    //call back functions
    var sideMenuTouched: (()->())?
    
    var profileTouched: (()->())?
    
    var fogTouched: (()->())?
    
    let fogView: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = .black
        view.layer.opacity = 0.3
        return view
    }()
    let emptyViewBoxForNavigationSpace: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    @objc func searchButtonTouchUp(){
        print(">>>>SEARCH BUTTON CLICKED!")
        UIView.animate(withDuration: 0.3, animations: {
            
            self.scrollView.layer.opacity -= 1
            self.navBar.layer.opacity -= 1
            
        }, completion: { isComp in
            if isComp {
                let view = SearchViewController()
                view.navBar.layer.opacity = 0
                view.scrollView.layer.opacity = 0
                self.navigationController?.pushViewController(view, animated: false)
                self.scrollView.layer.opacity = 1
                self.navBar.layer.opacity = 1
                UIView.animate(withDuration: 0.3, animations: {
                    view.navBar.layer.opacity += 1
                    view.scrollView.layer.opacity += 1
                })
            }
            
        })
    }
    
    @objc func sideMenuButtonTouchUp(){
        print(">>>>SIDE MENU BUTTON CLICKED!")
        self.view.addSubview(self.fogView)
        sideMenuTouched?()
    }
    
    @objc func profileButtonTouchUp(){
        print(">>>>PROFILE BUTTON CLICKED!")
        self.view.addSubview(self.fogView)
        profileTouched?()
        
    }
    
    @objc func fogTouchUP(){
        print(">>>>FOGVIEW BUTTON CLICKED!")
        fogView.removeFromSuperview()
        fogTouched?()
        
    }
    @objc func handleRefreshControl() {
        // Update your content…
        loadData()
        Auth.auth().currentUser?.reload()
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    func loadData(){
        //        otherLimeRoomScrollView.reload()
        
        Task.init {
            do{
                self.startLoading()
                self.limeTrendCollectionView.data = try await repository?.getLimeTrendsData()?.trendsList ?? []
                guard let uid = Auth.auth().currentUser?.uid else{
                    return
                }
                guard let typeName = try await repository?.getUserData(uid: uid)?.personalityType else {
                    return
                }
                self.myRoomName = typeName
                self.myLimeRoomLoggedView.boardName = self.myRoomName
                print(">>>> typeName: \(typeName)")
                self.stopLoading()
            }catch{
                print(">>>> myTypeName 가져오는데 실패\(error)")
                self.stopLoading()
            }
        }
    }
    
    // MARK: - UI Configuration and Setup
    func configure(){
        
        let refresh: UIRefreshControl = UIRefreshControl()
        self.scrollView.refreshControl = refresh
        self.scrollView.refreshControl?.addTarget(self, action:
                                                    #selector(handleRefreshControl),
                                                  for: .valueChanged)
        self.scrollView.delegate = self
        //DATA ASSIGNMENT
        
        
        navBar.dropDownTableClicked = { name in
            let boardV = BoardViewController()
            boardV.boardName = name
            boardV.boardNavBar.title.text = name
            self.navBar.isDropDown = false
            self.navigationController?.pushViewController(boardV, animated: true)
        }
        
        //Navigation Disable
        self.navigationController?.navigationBar.isHidden = true
        
        
        //VIEW CONFIGURATION
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .systemBackground
        contentView.axis = .vertical
        contentView.spacing = 30
        contentView.distribution = .fill
        navBar.delegate = self
        navBar.title.text = "SomLiMe"
        fogView.addTarget(self, action: #selector(fogTouchUP), for: .touchUpInside)
        
        myLimeRoomNotLoggedView.isHidden = true
        myLimeRoomLoggedView.isHidden = true
        
        myLimeRoomLoggedView.onClickMoreButton = { str in
            let vc = BoardViewController()
            vc.boardName = str ?? "광장"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        myLimeRoomLoggedView.onClickPostCell = { meta in
            let vc = BoardPostViewController()
            vc.boardName = meta.boardID
            vc.postId = meta.postID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        myLimeRoomNotLoggedView.logingInButton = {
            self.navigationController?.pushViewController(LogInViewController(), animated: true)
        }
        otherLimeRoomScrollView.cellTouchedUp = { boardName in
            
            let vc = BoardViewController()
            vc.boardName = boardName
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //Router
        limesToday.navigateToPost = { pid in
            let boardV = BoardPostViewController()
            boardV.boardName = self.limesToday.tapView.currentTab
            boardV.postId = pid
            self.navigationController?.pushViewController(boardV, animated: true)
        }
        limesToday.navigateToBoard = { bName in
            let boardV = BoardViewController()
            boardV.boardName = self.limesToday.tapView.currentTab
            self.navigationController?.pushViewController(boardV, animated: true)
        }
        limeTrendCollectionView.onCapsuleTapped = { trendItemString in
            //트렌드 내용에 따라서 검색해야됨
            print(">>>> 트렌드 \(trendItemString)")
        }
        //ADD SUBVIEWS
        view.addSubview(scrollView)
        view.addSubview(navBar)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(emptyViewBoxForNavigationSpace)
        contentView.addArrangedSubview(myLimeRoomNotLoggedView)
        contentView.addArrangedSubview(myLimeRoomLoggedView)
        contentView.addArrangedSubview(otherLimeRoomScrollView)
        contentView.addArrangedSubview(limeTrendCollectionView)
        contentView.addArrangedSubview(limesToday)
        contentView.addArrangedSubview(limeTest)
        
        
    }
    
    // MARK: - UI Layout Setup
    func setupLayout(){
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        emptyViewBoxForNavigationSpace.heightAnchor.constraint(equalTo: navBar.heightAnchor, multiplier: 0.4).isActive = true
        
        self.scrollViewTopConstraint = scrollView.topAnchor.constraint(equalTo: self.view.topAnchor)
        NSLayoutConstraint.activate([
            scrollViewTopConstraint!,
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAuth.Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.myLimeRoomNotLoggedView.isHidden = true
                self.myLimeRoomLoggedView.isHidden = false
            }else {
                
                self.myLimeRoomNotLoggedView.isHidden = false
                self.myLimeRoomLoggedView.isHidden = true
            }
        }
        loadData()
        configure()
        setupLayout()
    }
    
    
    
}
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            self.scrollViewTopConstraint?.constant = -scrollView.contentOffset.y/2
        } else {
            self.scrollViewTopConstraint?.constant = 0
        }
    }
}
