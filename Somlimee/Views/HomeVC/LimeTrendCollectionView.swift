//
//  LimeTrendCollectionView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/06/13.
//

import UIKit

class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 7
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let attributes = super.layoutAttributesForElements(in: rect)
 
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}

class LimeTrendCollectionView: UIView {
    
    
    private let cellIdentifier = "CapsuleCell"
    var data: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var onCapsuleTapped: ((String) -> Void)?
    
    private let container: UIStackView = UIStackView()
    private var collectionView: UICollectionView
    private let title: UILabel = UILabel()
    
    private func configureUI() {
        
        backgroundColor = .white
        
        //컨테이너 설정
        container.axis = .vertical
        container.distribution = .fill
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        //컬렉션 뷰 설정
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = SomLimeColors.backgroundColor
        
        //타이틀 설정
        title.text = "라임 트렌드"
        title.font = UIFont.hanSansNeoBold(size: 21)
        
        
        // Add the collection view
        addSubview(container)
        container.addArrangedSubview(title)
        container.addArrangedSubview(collectionView)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            self.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        
        // Register collection view cell
        collectionView.register(LimeTrendCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // Set the data source and delegate for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    
    override init(frame: CGRect) {
        let layout = CollectionViewLeftAlignFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        let layout = CollectionViewLeftAlignFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }
    
    
}

extension LimeTrendCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? LimeTrendCollectionViewCell else {
            return UICollectionViewCell()
        }
        let text = data[indexPath.item]
        cell.textLabel.text = text
        return cell
    }
}

extension LimeTrendCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = data[indexPath.item]
        onCapsuleTapped?(text)
    }
}

extension LimeTrendCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = data[indexPath.item]
        let width = text.width(withConstrainedHeight: 30, font: UIFont.hanSansNeoMedium(size: 16)) + 30
        return CGSize(width: width, height: 30) // 캡슐 높이는 고정값
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

class LimeTrendCollectionViewCell: UICollectionViewCell {
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.hanSansNeoMedium(size: 16)
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor =  SomLimeColors.primaryColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        isUserInteractionEnabled = true
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}
