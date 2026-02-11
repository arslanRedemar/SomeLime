//
//  PersonalityTestViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/03.
//

import UIKit
import FirebaseAuth
class PersonalityTestViewController: UIViewController{
    //Declare
    var questions: PersonalityTestQuestions? {
        didSet{
            questionLabel.text = questions?.questions[currentIndex]
        }
    }
    //var repository: PersonalityTestViewRepository?
    var currentIndex: Int = 0 {
        didSet{
            if currentIndex <= (questions?.questions.count ?? 0) - 1 {
                questionLabel.text = questions?.questions[currentIndex]
            }
        }
    }
    let questionLabel: UILabel = UILabel()
    let descriptionContainer: UIStackView = UIStackView()
    let descriptionLabel1: UILabel = UILabel()
    let descriptionLabel2: UILabel = UILabel()
    let descriptionLabel3: UILabel = UILabel()
    let descriptionLabel4: UILabel = UILabel()
    let descriptionLabel5: UILabel = UILabel()
    let answerBar: AnswerBarView = AnswerBarView()
    let nextButton: UIButton = UIButton()
    let warningLabel: UILabel = UILabel()
    var isSelected: Bool = false
    @objc private func onNextButtonClicked(){
        if !isSelected {
            warningLabel.text = "넘어가기 전에 선택 해주세요"
            return
        }
        warningLabel.text = ""
        self.currentIndex += 1
        self.answerBar.reset()
        isSelected = false
        if currentIndex > (questions?.questions.count ?? 0) - 1 {
            //
            var result: PersonalityTestResultData = PersonalityTestResultData(Strenuousness: 0, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: "")
            let vc = PersonalityTestResultViewController()
            if let test = questions{
                Task.init {
                    do{
                        result = calculateTestResult(test: test)
                        vc.testResult = result
//                        try await repository?.updatePersonalityTest(test: result, uid: FirebaseAuth.Auth.auth().currentUser?.uid ?? "")
                    }catch{
                        print("\(error)")
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        self.questionLabel.layer.opacity = 0
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.questionLabel.layer.opacity = 1
        })
        self.questions?.answers.append(Answer.Neutral)
    }
    //Load Data
    private func load(){
        Task.init {
            do{
//               questions = try await repository?.getQuestions()
            }catch{
                print(">>>>Load Failed : \(error)")
            }
        }
    }
    
    //Configure
    private func configure(){
        let q = questions?.questions.count ?? 1
        if q == 0 { // 데이터가 빈 배열일 경우를 제외
            return
        }
        descriptionContainer.distribution = .fillEqually
        questionLabel.text = questions?.questions[currentIndex] ?? "Error"
        questionLabel.font = UIFont.systemFont(ofSize: 20)
        descriptionLabel1.textAlignment = .center
        descriptionLabel1.text = "전혀 아니다"
        descriptionLabel1.font = UIFont.systemFont(ofSize: 11)
        
        descriptionLabel2.textAlignment = .center
        descriptionLabel2.text = "아니다"
        descriptionLabel2.font = UIFont.systemFont(ofSize: 11)
        
        descriptionLabel3.textAlignment = .center
        descriptionLabel3.text = "보통이다"
        descriptionLabel3.font = UIFont.systemFont(ofSize: 11)
        
        descriptionLabel4.textAlignment = .center
        descriptionLabel4.text = "그렇다"
        descriptionLabel4.font = UIFont.systemFont(ofSize: 11)
        
        descriptionLabel5.textAlignment = .center
        descriptionLabel5.text = "완전 그렇다"
        descriptionLabel5.font = UIFont.systemFont(ofSize: 11)
        answerBar.onMarbleClick = [
            {
                self.questions?.answers[self.currentIndex] = .StronglyDisagree
                self.isSelected = true
            },
            {
                self.questions?.answers[self.currentIndex] = .Disagree
                self.isSelected = true
            },
            {
                self.questions?.answers[self.currentIndex] = .Neutral
                self.isSelected = true
            },
            {
                self.questions?.answers[self.currentIndex] = .Agree
                self.isSelected = true
            },
            {
                self.questions?.answers[self.currentIndex] = .StronglyAgree
                self.isSelected = true
            }
        ]
        nextButton.setTitle("다음", for: .normal)
        nextButton.setTitleColor(.label, for: .normal)
        nextButton.addTarget(self, action: #selector(onNextButtonClicked), for: .touchUpInside)
        warningLabel.textColor = .red
    }
    //Layout
    private func layout(){
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        answerBar.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel)
        view.addSubview(descriptionContainer)
        view.addSubview(answerBar)
        view.addSubview(nextButton)
        view.addSubview(warningLabel)
        descriptionContainer.addArrangedSubview(descriptionLabel1)
        descriptionContainer.addArrangedSubview(descriptionLabel2)
        descriptionContainer.addArrangedSubview(descriptionLabel3)
        descriptionContainer.addArrangedSubview(descriptionLabel4)
        descriptionContainer.addArrangedSubview(descriptionLabel5)
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            questionLabel.heightAnchor.constraint(equalToConstant: view.frame.height*0.2),
        ])
        NSLayoutConstraint.activate([
            descriptionContainer.topAnchor.constraint(equalTo: self.questionLabel.bottomAnchor, constant: 10),
            descriptionContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            descriptionContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        ])
        NSLayoutConstraint.activate([
            answerBar.topAnchor.constraint(equalTo: self.descriptionContainer.bottomAnchor, constant: 10),
            answerBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            answerBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        ])
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: self.answerBar.bottomAnchor, constant: 10),
            warningLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        ])
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: self.warningLabel.bottomAnchor, constant: 20),
            nextButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: view.frame.height*0.1),
        ])

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //repository = PersonalityTestViewRepositoryImpl()
        load()
        configure()
        layout()
        view.backgroundColor = .systemGray3
    }
    
}
