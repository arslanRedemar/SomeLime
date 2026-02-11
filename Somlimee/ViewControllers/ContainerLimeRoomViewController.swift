//
//  ContainerBoardVC.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/09.
//

import UIKit


// MARK: - Fixtures

final class ContainerLimeRoomViewController: UIViewController {
    
    let profileVC: ProfileViewController = ProfileViewController()
    let limeRoomVC: LimeRoomViewController = LimeRoomViewController()
    var profileConstraint: NSLayoutConstraint?
    var offSetValue: CGFloat = 0
    
    var boardName: String? {
        didSet{
            limeRoomVC.boardName = boardName ?? ""
        }
    }
    
    var fogTouched: (()->())?
    
    
    let fogView: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = .black
        view.layer.opacity = 0.3
        view.isHidden = true
        return view
    }()
    
    
    @objc func fogTouchUP(){
        print(">>>>FOGVIEW BUTTON CLICKED!")
        fogView.isHidden = true
        fogTouched?()
    }
    
    // MARK: - UI Object Views Properties List
    
    
    func addInitialChildVC(){
        
        
        addChild(profileVC)
        profileVC.didMove(toParent: self)
        addChild(limeRoomVC)
        limeRoomVC.didMove(toParent: self)
        view.addSubview(limeRoomVC.view)
        view.addSubview(fogView)
        view.addSubview(profileVC.view)
        
        
    }
    func layout() {
        profileConstraint = profileVC.view.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        profileConstraint?.isActive = true
        NSLayoutConstraint.activate([
            profileVC.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            profileVC.view.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
        ])
    }
    
    
    func configureVC(){
        
        offSetValue = self.view.frame.width * 0.8
        self.navigationController?.isNavigationBarHidden = true
        
        fogView.addTarget(self, action: #selector(fogTouchUP), for: .touchUpInside)
        
        limeRoomVC.limeRoomNavBar.profileButtonTouchUpFunc = {
            
            self.profileConstraint?.constant -= self.offSetValue
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.view.layoutIfNeeded()
            })
            self.fogView.isHidden = false
        }
        
        self.fogTouched = {
            self.profileConstraint?.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn ,animations: {
                self.view.layoutIfNeeded()
            })
            self.fogView.isHidden = true
        }
        
        profileVC.navigateToLogin = {
            self.navigationController?.pushViewController(LogInViewController(), animated: true)
            self.fogTouchUP()
        }
        
        profileVC.navigateToVerifyEmail = {
            let vc = VerifyEmailViewController()
            vc.verifyButtonTouched()
            self.navigationController?.pushViewController(vc, animated: true)
            self.fogTouchUP()
            
        }
        
        profileVC.navigateToPersonalityTest = {
            let vc = PersonalityTestViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            self.fogTouchUP()
        }
        
        profileVC.navigateTestResultDetail = {
            let vc = PersonalityTestResultViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            self.fogTouchUP()
        }
        
        profileVC.onTouchedMyComments = {
            let vc = UserCurrentCommentsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            self.fogTouchUP()
        }
        
        profileVC.onTouchedMyPosts = {
            let vc = UserCurrentPostsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            self.fogTouchUP()
        }
        
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addInitialChildVC()
        configureVC()
        layout()
    }
}

