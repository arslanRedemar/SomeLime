//
//  LimeRoomScrollView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/06/07.
//

import UIKit

class OtherLimeRoomsScrollView: UIView {
    
    
    var cellTouchedUp: ((String)->Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "라임방 둘러보기"
        label.font = UIFont.hanSansNeoBold(size: 21)
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
    
    private let cellIdentifier = "LimeRoomCell"
    
    var data: [UIImage] = [UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!,UIImage(named: "limes")!]
    var dataString: [String] = ["SDE","SDR","SDD","RDE","RDR","RDD","HDE","HDR","HDD","CDE","CDR","CDD","NDE","NDR","NDD"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the title label
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        // Add the collection view
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // Register collection view cell
        collectionView.register(OtherLimeRoomsScrollViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // Set the data source and delegate for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // Additional methods and implementation for the collection view
    
}

extension OtherLimeRoomsScrollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? OtherLimeRoomsScrollViewCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = data[indexPath.item]
        cell.label.text = dataString[indexPath.item]
        return cell
    }
}

extension OtherLimeRoomsScrollView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cellTouchedUp?(dataString[indexPath.item])
    }
}
class OtherLimeRoomsScrollViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 13
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.hanSansNeoRegular(size: 14)
        label.textAlignment = .center
        label.textColor = .label
        return label
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
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor), // Square image view
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
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
extension OtherLimeRoomsScrollView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView , layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the desired size for each cell
        let cellWidth = collectionView.bounds.width * 0.2
        let cellHeight = collectionView.bounds.height * 0.8
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
