//
//  PTChartView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/08/06.
//

import UIKit

class PTChartView: UIView {
    
    var chartData: [Int]? {
        didSet{
            guard let chData = chartData else{
                return
            }
            let biggest = chData.max()!
            NSLayoutConstraint.activate([
                strBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: (Double(chData[0])/Double(biggest)) - 0.2),
                recBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: (Double(chData[1])/Double(biggest)) - 0.2),
                harBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: (Double(chData[2])/Double(biggest)) - 0.2),
                coaBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: (Double(chData[3])/Double(biggest)) - 0.2),
            ])
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    let containerVStack: UIStackView = UIStackView()
    let axisX: UIView = UIView()
    let barHStack: UIStackView = UIStackView()
    
    let strBar: UIView = UIView()
    let recBar: UIView = UIView()
    let harBar: UIView = UIView()
    let coaBar: UIView = UIView()
    
    let emptyBar1: UIView = UIView()
    let emptyBar2: UIView = UIView()
    
    let labelHStack: UIStackView = UIStackView()
    
    let strLabel: UILabel = UILabel()
    let recLabel: UILabel = UILabel()
    let harLabel: UILabel = UILabel()
    let coaLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setup
        translatesAutoresizingMaskIntoConstraints = false
        containerVStack.translatesAutoresizingMaskIntoConstraints = false
        axisX.translatesAutoresizingMaskIntoConstraints = false
        barHStack.translatesAutoresizingMaskIntoConstraints = false
        strBar.translatesAutoresizingMaskIntoConstraints = false
        recBar.translatesAutoresizingMaskIntoConstraints = false
        harBar.translatesAutoresizingMaskIntoConstraints = false
        coaBar.translatesAutoresizingMaskIntoConstraints = false
        emptyBar1.translatesAutoresizingMaskIntoConstraints = false
        emptyBar2.translatesAutoresizingMaskIntoConstraints = false
        labelHStack.translatesAutoresizingMaskIntoConstraints = false
        strLabel.translatesAutoresizingMaskIntoConstraints = false
        recLabel.translatesAutoresizingMaskIntoConstraints = false
        harLabel.translatesAutoresizingMaskIntoConstraints = false
        coaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        axisX.backgroundColor = SomLimeColors.lightPrimaryColor
        barHStack.axis = .horizontal
        barHStack.distribution = .equalSpacing
        barHStack.alignment = .trailing
        barHStack.spacing = 50
        
        containerVStack.axis = .vertical
        containerVStack.distribution = .equalSpacing
        containerVStack.alignment = .center
        containerVStack.spacing = 5
        
        labelHStack.axis = .horizontal
        labelHStack.distribution = .equalSpacing
        labelHStack.alignment = .lastBaseline
        
        strBar.backgroundColor = SomLimeColors.lightPrimaryColor
        recBar.backgroundColor = SomLimeColors.lightPrimaryColor
        harBar.backgroundColor = SomLimeColors.lightPrimaryColor
        coaBar.backgroundColor = SomLimeColors.lightPrimaryColor
        
        strLabel.text = "활력성"
        strLabel.font = .hanSansNeoMedium(size: 14)
        strLabel.textAlignment = .center
        
        recLabel.text = "수용성"
        recLabel.font = .hanSansNeoMedium(size: 14)
        recLabel.textAlignment = .center
        
        harLabel.text = "조화성"
        harLabel.font = .hanSansNeoMedium(size: 14)
        harLabel.textAlignment = .center
        
        coaLabel.text = "결집성"
        coaLabel.font = .hanSansNeoMedium(size: 14)
        coaLabel.textAlignment = .center
        
        self.addSubview(containerVStack)
        self.addSubview(axisX)
        containerVStack.addArrangedSubview(barHStack)
        containerVStack.addArrangedSubview(labelHStack)
        
        barHStack.addArrangedSubview(emptyBar1)
        barHStack.addArrangedSubview(strBar)
        barHStack.addArrangedSubview(recBar)
        barHStack.addArrangedSubview(harBar)
        barHStack.addArrangedSubview(coaBar)
        barHStack.addArrangedSubview(emptyBar2)
        
        labelHStack.addArrangedSubview(strLabel)
        labelHStack.addArrangedSubview(recLabel)
        labelHStack.addArrangedSubview(harLabel)
        labelHStack.addArrangedSubview(coaLabel)
        
        NSLayoutConstraint.activate([
            
            containerVStack.topAnchor.constraint(equalTo: self.topAnchor),
            containerVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            strBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            recBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            harBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            coaBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            
            emptyBar1.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            emptyBar2.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            
            axisX.widthAnchor.constraint(equalTo: widthAnchor, constant: -40),
            axisX.heightAnchor.constraint(equalToConstant: 2),
            axisX.centerXAnchor.constraint(equalTo: containerVStack.centerXAnchor),
            axisX.topAnchor.constraint(equalTo: barHStack.bottomAnchor),
            
            labelHStack.topAnchor.constraint(equalTo: axisX.bottomAnchor, constant: 10),
            labelHStack.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1),
            labelHStack.widthAnchor.constraint(equalTo: self.widthAnchor),
            labelHStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            strLabel.centerXAnchor.constraint(equalTo: strBar.centerXAnchor),
            
            recLabel.centerXAnchor.constraint(equalTo: recBar.centerXAnchor),
            
            harLabel.centerXAnchor.constraint(equalTo: harBar.centerXAnchor),
            
            coaLabel.centerXAnchor.constraint(equalTo: coaBar.centerXAnchor),
            
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
