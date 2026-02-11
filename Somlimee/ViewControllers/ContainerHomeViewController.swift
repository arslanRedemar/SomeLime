//
//  ViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/02/24.
//

import UIKit


// MARK: - Fixtures

final class ContainerHomeViewController: UIViewController {
    
    var containerVM: ContainerViewModel?
    var navigationVC: UINavigationController = UINavigationController()
    
    let profileVC: ProfileViewController = ProfileViewController()
    let sideMenuVC: SideMenuViewController = SideMenuViewController()
    let navBar: HomeNavBar = HomeNavBar()
    let homeVC: HomeViewController = HomeViewController()
    
    var offSetValue: CGFloat = 0
    
    
    
    // MARK: - UI Object Views Properties List
    
    func configureContainerVC() {
        containerVM = AppDelegate.container.resolve(ContainerViewModel.self)
    }
    
    func addInitialChildVC(){
        
        addChild(sideMenuVC)
        sideMenuVC.didMove(toParent: self)
        view.addSubview(sideMenuVC.view)
        
        addChild(profileVC)
        profileVC.didMove(toParent: self)
        view.addSubview(profileVC.view)
        
        addChild(navigationVC)
        navigationVC = UINavigationController(rootViewController: homeVC)
        navigationVC.didMove(toParent: self)
        view.addSubview(navigationVC.view)
        
    }
    func layout() {
        
        NSLayoutConstraint.activate([
            profileVC.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            profileVC.view.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            profileVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            sideMenuVC.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            sideMenuVC.view.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            sideMenuVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    func configureVC(){
        
        
        homeVC.sideMenuTouched = {
            self.sideMenuVC.view.frame.origin.x = -self.offSetValue
            self.profileVC.view.frame.origin.x = self.view.frame.width
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.navigationVC.view.frame.origin.x += self.offSetValue
                self.sideMenuVC.view.frame.origin.x = 0
            })
        }
        
        homeVC.profileTouched = {
            self.profileVC.view.frame.origin.x = self.view.frame.width
            self.sideMenuVC.view.frame.origin.x = -self.offSetValue
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.navigationVC.view.frame.origin.x -= self.offSetValue
                self.profileVC.view.frame.origin.x -= self.offSetValue
            })
        }
        
        homeVC.fogTouched = {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.navigationVC.view.frame.origin.x = 0
                self.sideMenuVC.view.frame.origin.x = -self.offSetValue
                self.profileVC.view.frame.origin.x = self.view.frame.width
            })
        }
        
        profileVC.navigateToLogin = {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.navigationVC.view.frame.origin.x = 0
                self.sideMenuVC.view.frame.origin.x = -self.offSetValue
                self.profileVC.view.frame.origin.x = self.view.frame.width
            }, completion: {isComp in self.navigationVC.pushViewController(LogInViewController(), animated: true)
                self.homeVC.fogTouchUP()
            })
        }
        profileVC.navigateToVerifyEmail = {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.navigationVC.view.frame.origin.x = 0
                self.sideMenuVC.view.frame.origin.x = -self.offSetValue
                self.profileVC.view.frame.origin.x = self.view.frame.width
            }, completion: {isComp in
                let vc = VerifyEmailViewController()
                vc.verifyButtonTouched()
                self.navigationVC.pushViewController(vc, animated: true)
                self.homeVC.fogTouchUP()
            })
        }
        
        profileVC.navigateToPersonalityTest = {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.navigationVC.view.frame.origin.x = 0
                self.sideMenuVC.view.frame.origin.x = -self.offSetValue
                self.profileVC.view.frame.origin.x = self.view.frame.width
                
            }, completion: {isComp in
                let vc = PersonalityTestViewController()
                self.navigationVC.pushViewController(vc, animated: true)
                self.homeVC.fogTouchUP()
            })
        }
        
        
        homeVC.myLimeRoomLoggedView.onClickMoreButton = { str in
            let vc = BoardViewController()
            vc.boardName = str ?? "광장"
            self.navigationVC.pushViewController(vc, animated: true)
        }
        
        homeVC.myLimeRoomLoggedView.onClickPostCell = { meta in
            let vc = BoardPostViewController()
            vc.boardName = meta.boardID
            vc.postId = meta.postID
            self.navigationVC.pushViewController(vc, animated: true)
        }
        
        homeVC.myLimeRoomNotLoggedView.logingInButton = {
            let vc = LogInViewController()
            self.navigationVC.pushViewController(vc, animated: true)
        }
        
        homeVC.otherLimeRoomScrollView.cellTouchedUp = { boardName in
            let vc = BoardViewController()
            vc.boardName = boardName
            self.navigationVC.pushViewController(vc, animated: true)
        }
        
        //Router
        homeVC.limesToday.navigateToPost = { pid in
            
            let boardV = BoardPostViewController()
            boardV.boardName = self.homeVC.limesToday.tapView.currentTab
            boardV.postId = pid
            self.navigationVC.pushViewController(boardV, animated: true)
            
        }
        
        homeVC.limesToday.navigateToBoard = { bName in
            
            let boardV = BoardViewController()
            boardV.boardName = self.homeVC.limesToday.tapView.currentTab
            self.navigationVC.pushViewController(boardV, animated: true)
            
        }
        
        homeVC.limeTrendCollectionView.onCapsuleTapped = { trendItemString in
            //트렌드 내용에 따라서 검색해야됨
            print(">>>> 트렌드 \(trendItemString)")
        }
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addInitialChildVC()
        configureContainerVC()
        configureVC()
        layout()
    }
}

