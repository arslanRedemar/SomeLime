//
//  LogInViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/23.
//

import UIKit



class LogInViewController: UIViewController {
    
    // UI 컴포넌트 선언
    private let logoContainerView = UIView()
    private let logoImageView = UIImageView(image: UIImage(named: "loginlogo"))
    private let idTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let passwordRecoveryButton = UIButton(type: .system)
    private let idRecoveryButton = UIButton(type: .system)
    private let signupButton = UIButton(type: .system)
    private let verticalLineView1 = UIView()
    private let verticalLineView2 = UIView()
    private let buttonStackEmptyLeading = UIView()
    private let buttonStackEmptyTrailing = UIView()
    private let mainStackView = UIStackView()
    private let buttonStackView = UIStackView()
    private let backButton = UIButton(type: .system)
    
    
    @objc func loginClicked(){
        let id = self.idTextField.text ?? ""
        let pw = self.passwordTextField.text ?? ""
        let lv = LoadingView()
        Task.init {
            do{
                print("logging in")
                view.addSubview(lv)
                NSLayoutConstraint.activate([
                    lv.topAnchor.constraint(equalTo: view.topAnchor),
                    lv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    lv.leftAnchor.constraint(equalTo: view.leftAnchor),
                    lv.rightAnchor.constraint(equalTo: view.rightAnchor)
                ])
                view.setNeedsLayout()
                view.layoutIfNeeded()
                //try await UserLoginFunctions.signIn(ID: id, PW: pw)
                print("logged in successfully")
                view.willRemoveSubview(lv)
                view.setNeedsLayout()
                view.layoutIfNeeded()
                navigationController?.popToRootViewController(animated: true)
            }catch{
                
                view.willRemoveSubview(lv)
                
                view.setNeedsLayout()
                view.layoutIfNeeded()
                print("not logged in...\(error)")
            }
        }
    }
    @objc private func backButtonTapped() {
        // 백 버튼 클릭 시 동작
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureUI()
        layout()
    }
    
    private func configureUI() {
        // 로고 이미지 컨테이너 뷰
        logoContainerView.translatesAutoresizingMaskIntoConstraints = false
        logoContainerView.backgroundColor = .clear
        
        // 로고 이미지 뷰
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 아이디 입력 필드
        idTextField.translatesAutoresizingMaskIntoConstraints = false
        idTextField.borderStyle = .none
        idTextField.placeholder = "아이디 또는 이메일"
        
        //백버튼
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        // 간격을 주기 위한 커스텀 뷰 생성
        let personImageContainerView = UIView()
        personImageContainerView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        let personImageView = UIImageView(image: UIImage(systemName: "person"))
        personImageView.contentMode = .scaleAspectFit
        personImageView.widthAnchor.constraint(equalToConstant: 23).isActive = true
        
        personImageContainerView.addSubview(personImageView)
        personImageView.centerXAnchor.constraint(equalTo: personImageContainerView.centerXAnchor).isActive = true
        personImageView.centerYAnchor.constraint(equalTo: personImageContainerView.centerYAnchor).isActive = true
        personImageView.tintColor = .lightGray
        // 레프트 뷰에 간격 뷰와 아이콘 이미지 뷰 추가
        idTextField.leftView = personImageContainerView
        
        idTextField.leftViewMode = .always
        
        idTextField.autocorrectionType = .no
        idTextField.autocapitalizationType = .none
        idTextField.keyboardType = .emailAddress
        idTextField.tintColor = .lightGray
        
        // 패스워드 입력 필드
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.borderStyle = .none
        passwordTextField.placeholder = "비밀번호"
        let lockImageContainerView = UIView()
        lockImageContainerView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        let lockImageView = UIImageView(image: UIImage(systemName: "lock"))
        lockImageView.contentMode = .scaleAspectFit
        lockImageView.widthAnchor.constraint(equalToConstant: 23).isActive = true
        lockImageContainerView.addSubview(lockImageView)
        lockImageView.centerXAnchor.constraint(equalTo: lockImageContainerView.centerXAnchor).isActive = true
        lockImageView.centerYAnchor.constraint(equalTo: lockImageContainerView.centerYAnchor).isActive = true
        passwordTextField.leftView = lockImageContainerView
        passwordTextField.leftViewMode = .always
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.tintColor = .lightGray
        passwordTextField.isSecureTextEntry = true
        
        // 아이디 입력 필드와 패스워드 입력 필드의 밑경계선 추가
        idTextField.addUnderlineBorder()
        passwordTextField.addUnderlineBorder()
        
        // 로그인 버튼
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("로그인", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = SomLimeColors.primaryColor
        loginButton.layer.cornerRadius = 15
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // 비밀번호 찾기 버튼
        passwordRecoveryButton.translatesAutoresizingMaskIntoConstraints = false
        passwordRecoveryButton.setTitle("비밀번호 찾기", for: .normal)
        passwordRecoveryButton.setTitleColor(.darkGray, for: .normal)
        passwordRecoveryButton.addTarget(self, action: #selector(passwordRecoveryButtonTapped), for: .touchUpInside)
        
        // 아이디 찾기 버튼
        idRecoveryButton.translatesAutoresizingMaskIntoConstraints = false
        idRecoveryButton.setTitle("아이디 찾기", for: .normal)
        idRecoveryButton.setTitleColor(.darkGray, for: .normal)
        idRecoveryButton.addTarget(self, action: #selector(idRecoveryButtonTapped), for: .touchUpInside)
        
        // 회원가입 버튼
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.setTitleColor(.darkGray, for: .normal)
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        
        
        
        // 수직 경계선 뷰
        verticalLineView1.translatesAutoresizingMaskIntoConstraints = false
        verticalLineView1.backgroundColor = .lightGray
        
        verticalLineView2.translatesAutoresizingMaskIntoConstraints = false
        verticalLineView2.backgroundColor = .lightGray
        
        buttonStackEmptyLeading.translatesAutoresizingMaskIntoConstraints = false
        buttonStackEmptyLeading.backgroundColor = .clear
        
        buttonStackEmptyTrailing.translatesAutoresizingMaskIntoConstraints = false
        buttonStackEmptyTrailing.backgroundColor = .clear
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        // 메인 스택뷰
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
    }
    
    private func layout() {
        // 로고 이미지 컨테이너 뷰
        view.addSubview(logoContainerView)
        
        NSLayoutConstraint.activate([
            logoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            logoContainerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            logoContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        // 로고 이미지 뷰
        logoContainerView.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalTo: logoContainerView.widthAnchor, multiplier: 0.5),
            logoImageView.heightAnchor.constraint(equalTo: logoContainerView.heightAnchor, multiplier: 0.5)
        ])
        
        // 메인 스택뷰
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        // 아이디 입력 필드
        idTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mainStackView.addArrangedSubview(idTextField)
        
        // 패스워드 입력 필드
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mainStackView.addArrangedSubview(passwordTextField)
        
        // 로그인 버튼
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mainStackView.addArrangedSubview(loginButton)
        
        // 스택뷰 수직 경계선 뷰 추가
        
        buttonStackView.addArrangedSubview(buttonStackEmptyLeading)
        buttonStackView.addArrangedSubview(idRecoveryButton)
        buttonStackView.addArrangedSubview(verticalLineView1)
        buttonStackView.addArrangedSubview(passwordRecoveryButton)
        buttonStackView.addArrangedSubview(verticalLineView2)
        buttonStackView.addArrangedSubview(signupButton)
        buttonStackView.addArrangedSubview(buttonStackEmptyTrailing)
        mainStackView.addArrangedSubview(buttonStackView)
        
        // 수직 경계선 뷰 크기 설정
        verticalLineView1.widthAnchor.constraint(equalToConstant: 2).isActive = true
        verticalLineView2.widthAnchor.constraint(equalToConstant: 2).isActive = true
        
        buttonStackEmptyLeading.widthAnchor.constraint(equalToConstant: 5).isActive = true
        buttonStackEmptyTrailing.widthAnchor.constraint(equalToConstant: 5).isActive = true
        
        // 상위 뷰에 백 버튼 추가
        view.addSubview(backButton)

        // 백 버튼의 크기와 위치를 설정
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // 버튼 액션 함수들
    @objc private func loginButtonTapped() {
        // 로그인 버튼 클릭 시 동작
        loginClicked()
    }
    
    @objc private func passwordRecoveryButtonTapped() {
        // 비밀번호 찾기 버튼 클릭 시 동작
    }
    
    @objc private func idRecoveryButtonTapped() {
        // 아이디 찾기 버튼 클릭 시 동작
    }
    
    @objc private func signupButtonTapped() {
        // 회원가입 버튼 클릭 시 동작
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
}
extension UITextField {
    func addUnderlineBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(bottomLine)
        
        // Update the constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 40)
            // Add other constraints as needed
        ])
    }
}

