//
//  BoardTableView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/25.
//

import UIKit

class LimeRoomPostListView: UITableView{
    
    var postItem: LimeRoomPostList? {
        didSet{
            self.reloadData()
            heightConstraint.isActive = false
            heightConstraint = self.heightAnchor.constraint(equalToConstant: CGFloat(postItem?.list.count ?? 0) * cellHeight)
            heightConstraint.isActive = true
        }
    }
    
    var didCellClicked: ((String)->Void)?
    private var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var cellHeight: CGFloat = 56{
        didSet{
            heightConstraint.isActive = false
            heightConstraint = self.heightAnchor.constraint(equalToConstant: CGFloat(postItem?.list.count ?? 0) * cellHeight)
            heightConstraint.isActive = true
        }
    }
    
    private let topBottomInsets: CGFloat = 10
    
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
        
        dataSource = self
        
        self.register(PostCellFullTypeView.self, forCellReuseIdentifier: String(describing: PostCellFullTypeView.self))
        
        let label = UILabel()
        label.text = "H"
        let image = UIImageView(image: UIImage(systemName: "person.fill"))
        cellHeight = (label.intrinsicContentSize.height + image.intrinsicContentSize.height) + topBottomInsets
        
        heightConstraint = self.heightAnchor.constraint(equalToConstant: CGFloat(postItem?.list.count ?? 0) * cellHeight)
        heightConstraint.isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension LimeRoomPostListView: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postItem?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: String(describing: PostCellFullTypeView.self), for: indexPath) as! PostCellFullTypeView
        cell.data = self.postItem?.list[indexPath.item]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cellForRow(at: indexPath) as! PostCellFullTypeView
        didCellClicked?(cell.postID ?? "")
    }
}

