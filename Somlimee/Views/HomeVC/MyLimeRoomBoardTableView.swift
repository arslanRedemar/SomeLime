//
//  MyLimeRoomBoardTableView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/31.
//

import UIKit

class MyLimeRoomBoardTableView: UITableView {
    var data: [BoardPostMetaData]?{
        didSet{
            self.reloadData()
        }
    }
    var onCellClicked: ((BoardPostMetaData)->Void)?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initializeTableView()
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false
        self.register(MyLimeRoomBoardTableViewCell.self, forCellReuseIdentifier: String(describing: MyLimeRoomBoardTableViewCell.self))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyLimeRoomBoardTableView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyLimeRoomBoardTableViewCell.self), for: indexPath) as! MyLimeRoomBoardTableViewCell
        let rawTimeData = data?[indexPath.item].publishedTime ?? "ERROR"
        if rawTimeData != "ERROR" {
            let startIndex = rawTimeData.index(rawTimeData.startIndex, offsetBy: 11)
            let endIndex = rawTimeData.index(rawTimeData.startIndex, offsetBy: 15)
            let substring = rawTimeData[startIndex...endIndex]
            cell.time.text = String(substring)
        } else {
            cell.time.text = rawTimeData
        }
        cell.title.text = data?[indexPath.item].postTitle ?? "데이터 로드 실패"
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onCellClicked?((data?[indexPath.item] ?? BoardPostMetaData(boardID: "", postID: "", publishedTime: "", postType: .text, postTitle: "", boardTap: "", userID: "", numberOfViews: 0, numberOfVoteUps: 0, numberOfComments: 0)))
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 17
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
}
class MyLimeRoomBoardTableViewCell: UITableViewCell{
    let container = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    let title = {
        let label = UILabel()
        label.font = .hanSansNeoRegular(size: 14)
        label.textColor = .label
        return label
    }()
    let time = {
        let label = UILabel()
        label.font = .hanSansNeoRegular(size: 14)
        label.textColor = SomLimeColors.labelLight
        return label
    }()
    let view = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(view)
        self.backgroundColor = .none
        self.selectionStyle = .none
        view.addSubview(container)
        container.addArrangedSubview(title)
        container.addArrangedSubview(time)
        view.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        time.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.widthAnchor.constraint(equalTo: self.widthAnchor),
            view.heightAnchor.constraint(equalTo: self.heightAnchor),
            title.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            time.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier:  0.2)
        ])
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            container.widthAnchor.constraint(equalTo: self.widthAnchor),
            container.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
