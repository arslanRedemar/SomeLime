//
//  ProfileTestResultVIew.swift
//  Somlimee
//
//  Created by Chanhee on 2023/08/15.
//

import UIKit

class ProfileTestResultView: UIView {
    
    //MARK: - Declaration of UI Components
    private let container: UIStackView = UIStackView()
    
    private let topHStackContainer: UIStackView = UIStackView()
    
    private let typeImageView: UIImageView = UIImageView()
    
    private let topVStackView: UIStackView = UIStackView()
    private let typeLabel: UILabel = UILabel()
    private let typeDetail: UILabel = UILabel()
    
    private let chartView: PTChartView = PTChartView()
    
    private let bottomHStackContainer: UIStackView = UIStackView()
    
    private let typePercentileImageView: UIImageView = UIImageView()
    private let bottomVStackContainer: UIStackView = UIStackView()
    
    private let bottomTypeName: UILabel = UILabel()
    private let bottomTypeDetail: UILabel = UILabel()
    
    private let bottomContainer: UIStackView = UIStackView()
    
    
    //MARK: - DATA
    
    internal var data: ProfileData? {
        didSet{
            guard let testData = data?.personalityTestResult else {
                return
            }
            let typeName = testData.type
            chartView.chartData = [testData.Strenuousness, testData.Receptiveness, testData.Harmonization, testData.Coagulation]
            typeLabel.text = typeName
            typeDetail.text = SomeLiMePTTypeDesc.typeDetail[typeName]
            bottomTypeName.text = typeName
            bottomTypeDetail.text = SomeLiMePTTypeDesc.typeDetail[typeName]
            
            typeImageView.image = UIImage(named: data?.personalityType ?? "")
            
            typePercentileImageView.image = UIImage(named: "perc" + (data?.personalityType ?? "Default"))
        }
    }
    
    
    //MARK: - Setup Functions
    
    private func trans(){
        translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        topHStackContainer.translatesAutoresizingMaskIntoConstraints = false
        typeImageView.translatesAutoresizingMaskIntoConstraints = false
        topVStackView.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeDetail.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        bottomHStackContainer.translatesAutoresizingMaskIntoConstraints = false
        typePercentileImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomVStackContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomTypeName.translatesAutoresizingMaskIntoConstraints = false
        bottomTypeDetail.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func setup(){
        
        addSubview(container)
        container.axis = .vertical
        container.alignment = .leading
        container.spacing = 20
        container.addArrangedSubview(topHStackContainer)
        container.addArrangedSubview(chartView)
        container.addArrangedSubview(bottomContainer)
        
        topHStackContainer.axis = .horizontal
        topHStackContainer.distribution = .fill
        topHStackContainer.spacing = 5
        topHStackContainer.addArrangedSubview(typeImageView)
        topHStackContainer.addArrangedSubview(topVStackView)
        
        typeImageView.image = UIImage(named: data?.personalityType ?? "")
        
        topVStackView.axis = .vertical
        topVStackView.alignment = .leading
        topVStackView.spacing = 2
        topVStackView.addArrangedSubview(typeLabel)
        topVStackView.addArrangedSubview(typeDetail)
        
        typeLabel.font = .hanSansNeoBold(size: 21)
        typeDetail.font = .hanSansNeoMedium(size: 16)
        
        bottomHStackContainer.axis = .horizontal
        bottomHStackContainer.distribution = .fill
        bottomHStackContainer.spacing = 10
        bottomHStackContainer.alignment = .center
        bottomHStackContainer.addArrangedSubview(typePercentileImageView)
        bottomHStackContainer.addArrangedSubview(bottomVStackContainer)
        
        typePercentileImageView.image = UIImage(named: "perc" + (data?.personalityType ?? "Default"))
        
        
        bottomContainer.axis = .vertical
        bottomContainer.alignment = .center
        bottomContainer.spacing = 5
        bottomContainer.addArrangedSubview(bottomHStackContainer)
        bottomVStackContainer.axis = .vertical
        bottomVStackContainer.alignment = .leading
        bottomVStackContainer.spacing = 5
        bottomVStackContainer.addArrangedSubview(bottomTypeName)
        bottomVStackContainer.addArrangedSubview(bottomTypeDetail)
        
        bottomTypeName.font = .hanSansNeoRegular(size: 12)
        bottomTypeDetail.font = .hanSansNeoRegular(size: 12)
    }
    
    private func layout(){
        NSLayoutConstraint.activate([
            
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            typeImageView.heightAnchor.constraint(equalToConstant: 60),
            typeImageView.widthAnchor.constraint(equalToConstant: 60),
            typePercentileImageView.heightAnchor.constraint(equalToConstant: 60),
            typePercentileImageView.widthAnchor.constraint(equalToConstant: 60),
            bottomContainer.widthAnchor.constraint(equalTo: container.widthAnchor),
            chartView.widthAnchor.constraint(equalTo: container.widthAnchor),
            topHStackContainer.widthAnchor.constraint(equalTo: container.widthAnchor),
            
        ])
        
    }
    
    
    //MARK: - Init Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        trans()
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
