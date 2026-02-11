//
//  PersonalityTestResultViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/04.
//

import UIKit

class PersonalityTestResultViewController: UIViewController{
    let chart: PTChartView = PTChartView()
    var testResult: PersonalityTestResultData? {
        didSet{
            guard let data = testResult else {
                return
            }
            chart.chartData = [data.Strenuousness, data.Receptiveness, data.Harmonization, data.Coagulation]
            typeLabel.text = data.type
            typeDetailLabel.text = SomeLiMePTTypeDesc.typeDetail[data.type]
            typeDescription.text = SomeLiMePTTypeDesc.typeDesc[data.type]
            
        }
    }
    let mainVStack: UIStackView = UIStackView()
    let titleLabel: UILabel = UILabel()
    let typeLabel: UILabel = UILabel()
    let typeDetailLabel: UILabel = UILabel()
    let firstLineHStack: UIStackView = UIStackView()
    let typeAndDetailLabel: UIStackView = UIStackView()
    
    let PTImageView: UIImageView = UIImageView()
    let PTSecondImageView: UIImageView = UIImageView()
    let typeDescription: UILabel = UILabel()
    let homeButton: UIButton = UIButton()
    
    @objc func onTouchHomeButton(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setup(){
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLineHStack.translatesAutoresizingMaskIntoConstraints = false
        typeAndDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        PTImageView.translatesAutoresizingMaskIntoConstraints = false
        PTSecondImageView.translatesAutoresizingMaskIntoConstraints = false
        typeDescription.translatesAutoresizingMaskIntoConstraints = false
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.backgroundColor = .white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.addSubview(mainVStack)
        view.addSubview(homeButton)
        
        
        mainVStack.axis = .vertical
        mainVStack.alignment = .leading
        mainVStack.spacing = 60
        for view in [titleLabel, firstLineHStack, chart, PTSecondImageView, typeDescription]{
            mainVStack.addArrangedSubview(view)
        }
        titleLabel.text = "테스트 결과"
        titleLabel.font = .hanSansNeoBold(size: 24)
        typeLabel.font = .hanSansNeoMedium(size: 20)
        typeDetailLabel.font = .hanSansNeoRegular(size: 18)
        typeDescription.font = .hanSansNeoRegular(size: 14)
        typeDescription.numberOfLines = 0
        firstLineHStack.axis = .horizontal
        firstLineHStack.distribution = .fill
        firstLineHStack.spacing = 10
        PTImageView.image = UIImage(named: "limes")
        firstLineHStack.addArrangedSubview(PTImageView)
        firstLineHStack.addArrangedSubview(typeAndDetailLabel)
        typeAndDetailLabel.axis = .vertical
        typeAndDetailLabel.distribution = .fill
        typeAndDetailLabel.addArrangedSubview(typeLabel)
        typeAndDetailLabel.addArrangedSubview(typeDetailLabel)
        PTSecondImageView.image = UIImage(named: "sadfrog")
        homeButton.tintColor = .label
        homeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        homeButton.addTarget(self, action: #selector(onTouchHomeButton), for: .touchUpInside)
        
        
    }
    func layout () {
        
        NSLayoutConstraint.activate([
            chart.heightAnchor.constraint(equalToConstant: 300),
            chart.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100),
            mainVStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainVStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainVStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            PTImageView.heightAnchor.constraint(equalToConstant: 40),
            PTImageView.widthAnchor.constraint(equalTo: PTImageView.heightAnchor),
            PTSecondImageView.heightAnchor.constraint(equalToConstant: 100),
            PTSecondImageView.widthAnchor.constraint(equalTo: mainVStack.widthAnchor),
            homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            homeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
}

