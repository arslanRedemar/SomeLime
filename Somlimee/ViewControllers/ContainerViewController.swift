//
//  ViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/02/24.
//

import UIKit


// MARK: - Fixtures

final class ContainerViewController: UIViewController {
    
    var navigationVC: UINavigationController = UINavigationController()
    
    let homeVC: HomeViewController = HomeViewController()
    
    let boardVC: BoardViewController = BoardViewController()
    
    let profileVC: ProfileViewController = ProfileViewController()
    
    let sideMenuVC: SideMenuViewController = SideMenuViewController()
    
    var offSetValue: CGFloat = 300
    // MARK: - UI Object Views Properties List
    
    func addChildVC(){
        
        addChild(sideMenuVC)
        sideMenuVC.didMove(toParent: self)
        view.addSubview(sideMenuVC.view)
        
        addChild(profileVC)
        profileVC.didMove(toParent: self)
        view.addSubview(profileVC.view)
        
        navigationVC = UINavigationController(rootViewController: homeVC)
        addChild(navigationVC)
        navigationVC.didMove(toParent: self)
        view.addSubview(navigationVC.view)
    }
    
    func configureVC(){
        
        // add dependencies
        homeVC.repository = HomeViewRepositoryImpl()
        
        offSetValue = view.frame.width * 0.8
        
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
        
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        configureVC()
    }
}

