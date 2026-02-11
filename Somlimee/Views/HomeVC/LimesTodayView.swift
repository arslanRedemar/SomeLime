//
//  LimesTodayView.swift
//  Somlimee
//
//  Created by Chanhee on 2023/06/13.
//

import UIKit

class LimesTodayView: UIStackView {
    
    let title: UILabel = UILabel()
    var navigateToBoard: ((String)->Void)? {
        didSet{
            self.tapView.navigateToBoard = navigateToBoard
        }
    }
    var navigateToPost: ((String)->Void)? {
        didSet{
            self.tapView.navigateToPost = navigateToPost
        }
    }
    let tapView: LimesTodayTapView = LimesTodayTapView()
    func configureUI(){
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.hanSansNeoBold(size: 21)
        title.text = "라임's Todays"
        self.axis = .vertical
        self.distribution = .fill
        addArrangedSubview(title)
        addArrangedSubview(tapView.view)
    }
    func layout(){
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 400),
        ])
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        layout()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
//상단의 탭 바 클래스
fileprivate class TapBarItem: HomeTabView{
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tapList?[indexPath.item] ?? "eoif"
        let width = text.width(withConstrainedHeight: 24, font: UIFont.hanSansNeoMedium(size: 14)) + 30
        return CGSize(width: width, height: 30) // 캡슐 높이는 고정값
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! HomeTabViewCell
        cell.index = indexPath.item
        cell.text = tapList?[indexPath.item] ?? ""
        if (indexPath.item == 0){
            
            let cornerRadius: CGFloat = 7
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft],
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
        } else if( indexPath.item == (self.tapList?.count ?? 99) - 1) {
            let cornerRadius: CGFloat = 7
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topRight],
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
        }
        return cell
    }
}

//탭 바와 그에 따른 테이블을 포함하는 뷰 컨트롤러
class LimesTodayTapView: UIViewController {
    
    let tabTitles = ["광장", "일상", "KPOP/연예", "스포츠"]
    
    var repository: HomeViewRepository?
    
    var navigateToBoard: ((String)->Void)?
    var navigateToPost: ((String)->Void)?
    
    fileprivate let tableView: LimesTodayTableView = {
        let tableView = LimesTodayTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let moveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setAttributedTitle(NSAttributedString(string: "게시판으로 이동", attributes: [ .font: UIFont.hanSansNeoRegular(size: 14)]), for: .normal)
        return button
    }()
    
    var currentTab: String = "광장"// 현재 선택된 탭 초기값
    fileprivate let boardTapView: TapBarItem = TapBarItem()
    let horizontalLine1: UIView = UIView()
    let horizontalLine2: UIView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        repository = HomeViewRepositoryImpl()
        initializeVC()
        setupViews()
        setupConstraints()
        moveButton.addTarget(self, action: #selector(moveToBoard), for: .touchUpInside)
    }
    
    func setupViews() {
        view.addSubview(boardTapView)
        view.addSubview(horizontalLine1)
        view.addSubview(tableView)
        view.addSubview(moveButton)
        view.addSubview(horizontalLine2)
        boardTapView.translatesAutoresizingMaskIntoConstraints = false
        boardTapView.tapList = tabTitles
        horizontalLine1.translatesAutoresizingMaskIntoConstraints = false
        horizontalLine2.translatesAutoresizingMaskIntoConstraints = false
        horizontalLine1.backgroundColor = SomLimeColors.primaryColor
        horizontalLine2.backgroundColor = SomLimeColors.lightPrimaryColor
        Task.init {
            do{
                self.tableView.data = try await self.repository?.getBoardHotPostsList(boardName: self.currentTab, startTime: "NaN", counts: 10) ?? []
            }
            catch{
                print(">>>> \(error)")
            }
        }
        boardTapView.cellClicked = { boardName in
            self.currentTab = boardName ?? "광장"
            Task.init {
                do{
                    self.tableView.data = try await self.repository?.getBoardHotPostsList(boardName: self.currentTab, startTime: "NaN", counts: 10) ?? []
                }
                catch{
                    print(">>>> \(error)")
                }
            }
            print(self.currentTab)
        }
        tableView.onCellClicked = { postId in
            self.navigateToPost?(postId)
        }
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            boardTapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            boardTapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boardTapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            boardTapView.heightAnchor.constraint(equalToConstant: 30),
            
            horizontalLine1.topAnchor.constraint(equalTo: boardTapView.bottomAnchor),
            horizontalLine1.leadingAnchor.constraint(equalTo: boardTapView.leadingAnchor),
            horizontalLine1.trailingAnchor.constraint(equalTo: boardTapView.trailingAnchor),
            horizontalLine1.heightAnchor.constraint(equalToConstant: 4),
            
            tableView.topAnchor.constraint(equalTo: horizontalLine1.bottomAnchor, constant:  17),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 250),
            
            moveButton.trailingAnchor.constraint(equalTo:tableView.trailingAnchor, constant: 0),
            moveButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            
            horizontalLine2.topAnchor.constraint(equalTo: moveButton.bottomAnchor, constant: 10),
            horizontalLine2.leadingAnchor.constraint(equalTo: boardTapView.leadingAnchor),
            horizontalLine2.trailingAnchor.constraint(equalTo: boardTapView.trailingAnchor),
            horizontalLine2.heightAnchor.constraint(equalToConstant: 4),
        ])
    }
    
    @objc func moveToBoard() {
        navigateToBoard?(currentTab)
    }
}

fileprivate class LimesTodayTableView: UITableView {
    
    var data: [BoardPostMetaData] = [] {
        didSet{
            reloadData()
        }
    }
    
    var onCellClicked: ((String)->Void)?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.initializeTableView()
        self.delegate = self
        self.dataSource = self
        self.translatesAutoresizingMaskIntoConstraints = false
        self.register(CustomTableViewCell.self, forCellReuseIdentifier: String(describing: CustomTableViewCell.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LimesTodayTableView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomTableViewCell.self), for: indexPath) as! CustomTableViewCell
        cell.titleLabel.text = data[indexPath.item].postTitle
        cell.titleLabel.textAlignment = .left
        cell.commentLabel.textAlignment = .right
        cell.commentLabel.text = "[\(data[indexPath.item].numberOfComments)]"
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onCellClicked?(data[indexPath.item].postID)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        25
    }
}
fileprivate class CustomTableViewCell: UITableViewCell {
    let container: UIStackView = UIStackView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.hanSansNeoMedium(size: 14)
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = SomLimeColors.secondaryColor
        label.font = UIFont.hanSansNeoMedium(size: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeView()
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(commentLabel)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8, constant: -30),
            commentLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2, constant: -10)
        ])
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

