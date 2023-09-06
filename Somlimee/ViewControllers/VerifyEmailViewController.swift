//
//  VerifyEmailViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/03.
//

import UIKit
import FirebaseAuth

class VerifyEmailViewController: UIViewController{
    
    let imageView: UIImageView = UIImageView(image: UIImage(named: "loginlogo"))
    let stackView: UIStackView = UIStackView()
    let textView: UILabel = UILabel()
    let checkBoxLabel: UILabel = UILabel()
    let checkBoxContainerStackView: UIStackView = UIStackView()
    let textView2: UILabel = UILabel()
    var timer: Timer?
    let timerLabel: UILabel = UILabel()
    var currentTask: Task<Void, Error>? = nil
    let emailResendButton: UIButton = UIButton()
    var seconds: Int = 150
    func updateLabel(){
        let min = seconds / 60
        let sec = seconds % 60
        
        if seconds == 0 {
            return
        }
        if sec < 10{
            timerLabel.text = String(min) + " : 0" + String(sec)
        }else{
            timerLabel.text = String(min) + " : " + String(sec)
        }
        
    }
    @objc func updateSeconds(){
        self.seconds -= 1
        print(seconds)
        updateLabel()
    }
    
    @objc func verifyButtonTouched(){
        print("verify button clicked")
        currentTask?.cancel()
        self.timer?.invalidate()
        self.seconds = 150
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSeconds), userInfo: nil, repeats: true)
        currentTask = Task.init {
            do{
                try await UserSignUpWithEmailService.sharedInstance.verifyEmail()
            }catch{
                print("\(error)")
            }
            while(!(Auth.auth().currentUser?.isEmailVerified ?? true)){
                try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                try? await Auth.auth().currentUser?.reload()
                if (self.seconds == 0) {
                    timer?.invalidate()
                    navigationController?.popToRootViewController(animated: true)
                    break
                }
            }
            if (Auth.auth().currentUser?.isEmailVerified ?? false) {
                self.checkBoxLabel.text = "이메일 인증 완료"
                self.checkBoxLabel.textColor = SomLimeColors.labelLight
                self.checkBoxContainerStackView.backgroundColor = SomLimeColors.primaryColor
                self.emailResendButton.isHidden = true
                self.textView2.isHidden = true
                try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                self.timer?.invalidate()
                self.navigationController?.pushViewController(PersonalityTestViewController(), animated: true)
            }
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener({ auth, user in
            print("email verification changed called")
            guard let result = user?.isEmailVerified else{
                return
            }
            if result {
                //verified -> check box and navigate to next vc
                print("email is verified")
                self.checkBoxLabel.text = "이메일 인증 완료"
                self.checkBoxLabel.textColor = .label
                self.checkBoxContainerStackView.setNeedsLayout()
                self.checkBoxContainerStackView.layoutIfNeeded()
                self.emailResendButton.isHidden = true
            }else{
                print("email is not verified")
            }
        })
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        emailResendButton.translatesAutoresizingMaskIntoConstraints = false
        checkBoxLabel.translatesAutoresizingMaskIntoConstraints = false
        checkBoxContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textView2.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SomLimeColors.backgroundColor
        imageView.contentMode = .scaleAspectFit
        checkBoxLabel.text = "이메일 인증 미완료"
        checkBoxLabel.textColor = .red
        checkBoxLabel.font = UIFont.hanSansNeoMedium(size: 16)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        timerLabel.font = .hanSansNeoBold(size: 20)
        timerLabel.textColor = SomLimeColors.primaryColor
        timerLabel.textAlignment = .center
        emailResendButton.setTitleColor(SomLimeColors.primaryColor, for: .normal)
        emailResendButton.addTarget(self, action: #selector(verifyButtonTouched), for: .touchUpInside)
        emailResendButton.setAttributedTitle(NSAttributedString(AttributedString("인증메일 재전송", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.hanSansNeoMedium(size: 14)]))), for: .normal)
        textView.text = "이메일 인증을 완료해야 활동이 가능합니다.\n 인증 완료하지 않을 시에 5일 후에 계정이\n삭제됩니다."
        textView.numberOfLines = 0
        textView.font = UIFont.hanSansNeoRegular(size: 16)
        textView.textAlignment = .center
        
        textView2.text = "인증 메일이 발송되었습니다. 메일을 열고 링크를 눌러주세요."
        textView2.numberOfLines = 0
        textView2.font = UIFont.hanSansNeoRegular(size: 14)
        textView2.textAlignment = .center
        checkBoxContainerStackView.axis = .horizontal
        checkBoxContainerStackView.distribution = .fill
        checkBoxContainerStackView.backgroundColor = SomLimeColors.systemGrayLight
        checkBoxContainerStackView.layer.cornerRadius = 15
        checkBoxLabel.textAlignment = .center
        view.addSubview(stackView)
        view.addSubview(emailResendButton)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(checkBoxContainerStackView)
        stackView.addArrangedSubview(timerLabel)
        stackView.addArrangedSubview(textView2)
        checkBoxContainerStackView.addArrangedSubview(checkBoxLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            checkBoxContainerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkBoxContainerStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            checkBoxContainerStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            timerLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            
            textView2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView2.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
        ])
        NSLayoutConstraint.activate([
            emailResendButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            emailResendButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
    
}
