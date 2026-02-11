//
//  PsyTestRecommendationSectionView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/06/28.
//

import UIKit

class LimeTestSectionView: UIView {
    
    
    var cellTouchedUp: ((String)->Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "라임 테스트"
        label.font = UIFont.hanSansNeoBold(size: 21)
        return label
    }()
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "썸라임에서 제공하는 특별한 심리테스트! \n라이머의 프로필에 추가해보세요!"
        label.numberOfLines = 0
        label.font = UIFont.hanSansNeoRegular(size: 14)
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        // Configure the collection view properties and delegate as needed
        
        return collectionView
    }()
    
    private let cellIdentifier = "LimeTestCell"
    
    private var data: [UIImage] = [UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!]
    private var dataString: [String] = ["test1","test2","test3","test1","test2","test3","test1","test2","test3","test1","test2","test3","test1","test2","test3"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
        setupView()
    }
    
    private func setupView() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        // Add the title label
        addSubview(titleLabel)
        addSubview(detailLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
        
        // Add the collection view
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        // Register collection view cell
        collectionView.register(LimeTestSectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // Set the data source and delegate for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // Additional methods and implementation for the collection view
    
}

extension LimeTestSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? LimeTestSectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = data[indexPath.item]
        return cell
    }
}

extension LimeTestSectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cellTouchedUp?(dataString[indexPath.item])
    }
}
class LimeTestSectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 13
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addShadow()
    }
    
    private func setupView() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),// Square image view
        ])
    }
    
    private func addShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
}
extension LimeTestSectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the desired size for each cell
        let cellWidth = collectionView.bounds.width * 0.7
        let cellHeight = collectionView.bounds.height * 0.8
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
extension LimeTestSectionView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
    }
}






