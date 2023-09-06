//
//  ProfileView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/23.
//

import UIKit
import FirebaseAuth


class ProfileViewController: UIViewController {
    
    //MARK: - Computed Properties
    
    var repository: ProfileViewRepository? {
        didSet{
            loadData()
        }
    }
    
    //MARK: - UI Components
    
    let containerVStack: UIStackView = UIStackView()
    
    //1
    let firstLineContainerHStack: UIStackView = UIStackView()
    let profileLabel: UILabel = UILabel()
    let profileSettingButton: UIButton = UIButton()
    
    //2
    let profileCardView: ProfileCardView = ProfileCardView()
    
    //3
    let testResultTitleLabel: UILabel = UILabel()
    
    //4
    let testResultContent: ProfileTestResultView = ProfileTestResultView()
    
    // 5-1
    let testResultDetailButtonContainer: UIStackView = UIStackView()
    
    // 5-2
    let testResultDetailButton: UIButton = UIButton()
    
    
    //9
    let loginButton: UIButton = UIButton()
    
    
    @objc func profileSettingButtonTouchUp(){
        print("profile button clicked")
        do { try UserLoginService.sharedInstance.logOut()
        } catch{
            print("logout error")
        }
    }
    
    @objc func testResultDetailButtonTouchUp(){
        print("test result detail button clicked")
    }
    
    @objc func recentPostDetailButtonTouchUp(){
        print("recent post detail button clicked")
    }
    
    @objc func mailButtonTouchUp(){
        print("alarmButton button clicked")
    }
    
    @objc func navigateToLoginView(){
        navigateToLogin?()
    }
    
    @objc func navigateToVerifyEmailView(){
        navigateToVerifyEmail?()
    }
    
    @objc func navigateToPersonalityTestView(){
        navigateToPersonalityTest?()
    }
    
    //MARK: - Delegate Properties (Undefined)
    var navigateToLogin: (()->())?
    var navigateToVerifyEmail: (()->())?
    var navigateToPersonalityTest: (()->())?
    
    
    func loadData(){
        Task.init {
            do{
                guard let data = try await repository?.getUserData(uid: FirebaseAuth.Auth.auth().currentUser?.uid ?? "") else {
                    print(">>>> COULD NOT LOAD USER DATA")
                    return
                }
                self.profileCardView.data = data
                testResultContent.data = data
            }catch{
                print("ERROR: \(error)")
            }
        }
        
    }
    private func configureUI(){
        
        //ADD SUBVIEWS
        self.view.addSubview(containerVStack)
        self.view.backgroundColor = .systemBackground
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        containerVStack.translatesAutoresizingMaskIntoConstraints = false
        firstLineContainerHStack.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileSettingButton.translatesAutoresizingMaskIntoConstraints = false
        profileCardView.translatesAutoresizingMaskIntoConstraints = false
        testResultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        testResultContent.translatesAutoresizingMaskIntoConstraints = false
        testResultDetailButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        testResultDetailButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        containerVStack.axis = .vertical
        containerVStack.distribution = .fill
        containerVStack.alignment = .leading
        containerVStack.spacing = 5
        containerVStack.addArrangedSubview(firstLineContainerHStack)
        containerVStack.addArrangedSubview(profileCardView)
        containerVStack.addArrangedSubview(testResultTitleLabel)
        containerVStack.addArrangedSubview(testResultContent)
        containerVStack.addArrangedSubview(testResultDetailButtonContainer)
        containerVStack.addArrangedSubview(loginButton)
        testResultDetailButtonContainer.addArrangedSubview(testResultDetailButton)
        testResultDetailButtonContainer.axis = .vertical
        testResultDetailButtonContainer.alignment = .trailing
        firstLineContainerHStack.axis = .horizontal
        firstLineContainerHStack.distribution = .equalSpacing
        firstLineContainerHStack.alignment = .leading
        firstLineContainerHStack.addArrangedSubview(profileLabel)
        firstLineContainerHStack.addArrangedSubview(profileSettingButton)
        
        profileLabel.text = "프로필"
        profileLabel.font = .hanSansNeoBold(size: 21)
        
        profileSettingButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        profileSettingButton.tintColor = SomLimeColors.label
        
        
        loginButton.setTitle("로그인하기", for: .normal)
        loginButton.setTitleColor(.label, for: .normal)
        loginButton.addTarget(self, action: #selector(navigateToLoginView), for: .touchUpInside)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        
        testResultTitleLabel.text = "성격테스트 결과"
        testResultTitleLabel.font = .hanSansNeoBold(size: 21)
        testResultDetailButton.setTitle("결과 리포트 보러가기 >", for: .normal)
        testResultDetailButton.setTitleColor(SomLimeColors.label, for: .normal)
        testResultDetailButton.tintColor = SomLimeColors.label
        testResultDetailButton.addTarget(self, action: #selector(testResultDetailButtonTouchUp), for: .touchUpInside)
        
        
        
    }
    
    private func setUpLayout(){
        
        NSLayoutConstraint.activate([
            containerVStack.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.8 - 20),
            containerVStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            containerVStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            testResultTitleLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1),
            testResultDetailButtonContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            testResultDetailButtonContainer.widthAnchor.constraint(equalTo: view.widthAnchor,constant: -20),
            
            testResultContent.widthAnchor.constraint(equalTo: view.widthAnchor),
            testResultContent.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            firstLineContainerHStack.widthAnchor.constraint(equalTo: containerVStack.widthAnchor),
            firstLineContainerHStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            profileCardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            profileCardView.widthAnchor.constraint(equalTo: containerVStack.widthAnchor),
            
        ])
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        repository = ProfileViewRepositoryImpl()
        FirebaseAuth.Auth.auth().addStateDidChangeListener({ auth, user in
            if user == nil {
                self.firstLineContainerHStack.isHidden = true
                self.profileSettingButton.isHidden = true
                self.profileCardView.isHidden = true
                self.testResultTitleLabel.isHidden = true
                self.testResultContent.isHidden = true
                self.testResultDetailButton.isHidden = true
                self.loginButton.isHidden = false
            }else{
                self.loadData()
                self.firstLineContainerHStack.isHidden = false
                self.profileSettingButton.isHidden = false
                self.profileCardView.isHidden = false
                self.testResultTitleLabel.isHidden = false
                self.testResultContent.isHidden = false
                self.testResultDetailButton.isHidden = false
                self.loginButton.isHidden = true
                
            }
        })
        configureUI()
        setUpLayout()
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            self.firstLineContainerHStack.isHidden = true
            self.profileSettingButton.isHidden = true
            self.profileCardView.isHidden = true
            self.testResultTitleLabel.isHidden = true
            self.testResultContent.isHidden = true
            self.testResultDetailButton.isHidden = true
            self.loginButton.isHidden = false
        }else{
            self.loadData()
            self.firstLineContainerHStack.isHidden = false
            self.profileSettingButton.isHidden = false
            self.profileCardView.isHidden = false
            self.testResultTitleLabel.isHidden = false
            self.testResultContent.isHidden = false
            self.testResultDetailButton.isHidden = false
            self.loginButton.isHidden = true
            
        }
    }
}
