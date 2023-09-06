//
//  SignUpViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/03.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    //Declare
    var isPasswordConfirmed = false {
        didSet{
            if isPasswordConfirmed {
                confirmIndicator.backgroundColor = SomLimeColors.primaryColor
                confirmIndicator.setNeedsLayout()
                confirmIndicator.layoutIfNeeded()
            }else{
                confirmIndicator.backgroundColor = SomLimeColors.secondaryColor
                confirmIndicator.setNeedsLayout()
                confirmIndicator.layoutIfNeeded()
            }
        }
    }
    var isEmailConfirmed = false {
        didSet{
            if isEmailConfirmed == false {
                emailTextField.textColor = .red
            }else{
                emailTextField.textColor = .label
            }
        }
    }
    var timer: Timer?
    
    let confirmIndicator = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 15
        label.textColor = .white
        label.text = "일치"
        label.font = UIFont.hanSansNeoBold(size: 14)
        label.backgroundColor = SomLimeColors.primaryColor
        return label
    }()
    
    let imageView = {
        let imageView = UIImageView(image: UIImage(named: "loginlogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Labels
    let signupLabel = {
        let signupLabel = UILabel()
        signupLabel.text = "회원가입"
        signupLabel.font = UIFont.hanSansNeoBold(size: 24)
        signupLabel.translatesAutoresizingMaskIntoConstraints = false
        return signupLabel
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.hanSansNeoBold(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 주소"
        label.font = UIFont.hanSansNeoBold(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.hanSansNeoBold(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.font = UIFont.hanSansNeoBold(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = .lightGray
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = .lightGray
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = .lightGray
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호 입력"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = .lightGray
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호 다시 입력"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Match Text for Confirm Password
    
    // Button
    let sendEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이메일 인증 보내기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendEmailButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Stack View for Labels and Text Fields
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(stackView)
        let views = [signupLabel,userNameLabel,userNameTextField, emailLabel, emailTextField, passwordLabel, passwordTextField, confirmPasswordLabel, horizontalStackView, sendEmailButton]
        for view in views {
            stackView.addArrangedSubview(view)
        }
        horizontalStackView.addArrangedSubview(confirmPasswordTextField)
        horizontalStackView.addArrangedSubview(confirmIndicator)
        confirmPasswordTextField.delegate = self
        emailTextField.delegate = self
        // Layout Constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func sendEmailButtonTapped() {
        // Handle the button tap action here
        if isPasswordConfirmed{
            //allow
            if isEmailConfirmed{
                Task.init{
                    do{
                        guard let ema = emailTextField.text else{
                            return
                        }
                        guard let pass = passwordTextField.text else {
                            return
                        }
                        guard let name = userNameTextField.text else {
                            return
                        }
                        try await UserSignUpWithEmailService.sharedInstance.createUser(Email: ema , PW: pass, userInfo: ProfileData(userName: name, profileImage: nil, totalUps: 0, signUpDate: Date.now.date.description, numOfPosts: 0, receivedUps: 0, points: 0, daysOfActive: 0, badges: [], personalityTestResult: PersonalityTestResultData(Strenuousness: 0, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: ""), personalityType: ""))
                        try await UserSignUpWithEmailService.sharedInstance.verifyEmail()
                        let vc = VerifyEmailViewController()
                        vc.verifyButtonTouched()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 타이머가 실행 중이면 invalidate하여 이전 타이머를 취소합니다.
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleTextFieldChange), userInfo: nil, repeats: false)
        
        return true
    }
    
    // 입력이 멈추었을 때 호출될 메서드
    @objc func handleTextFieldChange() {
        if passwordTextField.text == confirmPasswordTextField.text {
            isPasswordConfirmed = true
        }else {
            isPasswordConfirmed = false
        }
        let s = NSRange(location: 0, length: emailTextField.text?.utf16.count ?? 0)
        do{
            if try NSRegularExpression(pattern: "[a-z0-9]+@[a-z]+\\.[a-z]{2,3}").firstMatch(in: emailTextField.text ?? "", options: [], range: s) != nil{
                isEmailConfirmed = true
            }else{
                isEmailConfirmed = false
            }
        }catch{
            isEmailConfirmed = false
        }
        
    }
    
}
