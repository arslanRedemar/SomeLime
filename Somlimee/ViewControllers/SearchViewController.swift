//
//  SearchViewController.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/20.
//

import UIKit

class SearchViewController: UIViewController {

    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let contentView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emptyViewBoxForNavigationSpace: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let navBar: SearchNavBar = SearchNavBar()
    let searchHistorySuggestion: NormalTableView = NormalTableView()
    let searchRealTimeSuggestion: NormalTableView = NormalTableView()
    let searchedList: NormalTableView =  NormalTableView()
    
    
    @objc public func cancel(){
        UIView.animate(withDuration: 0.2, animations: {
            
            self.scrollView.layer.opacity -= 1
            self.navBar.layer.opacity -= 1
        }){isComp in
            let prev: HomeViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count ?? 2)-2] as! HomeViewController
            
            prev.scrollView.layer.opacity = 0
            prev.navBar.layer.opacity = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                prev.scrollView.layer.opacity += 1
                prev.navBar.layer.opacity += 1
            })
            self.navigationController?.popViewController(animated: false)
        }
    }
    func configure(){
        //Navigation Disable
        
        self.navigationController?.navigationBar.isHidden = true
        navBar.delegate = self
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(navBar)
        scrollView.addSubview(contentView)
        contentView.axis = .vertical
        contentView.spacing = 15
        contentView.distribution = .fill
        contentView.addArrangedSubview(emptyViewBoxForNavigationSpace)
        contentView.addArrangedSubview(searchHistorySuggestion)
        contentView.addArrangedSubview(searchRealTimeSuggestion)
        
        
        searchHistorySuggestion.data = ["ojfeoifj", "oefeojfioejf", "feoijiofejof","ojfeoifj", "oefeojfioejf", "feoijiofejof","ojfeoifj", "oefeojfioejf", "feoijiofejof"]
        searchRealTimeSuggestion.data = ["ojfeoifj", "oefeojfioejf", "feoijiofejof","ojfeoifj", "oefeojfioejf", "feoijiofejof","ojfeoifj", "oefeojfioejf", "feoijiofejof"]
    }
    func layout(){
        emptyViewBoxForNavigationSpace.heightAnchor.constraint(equalToConstant: self.view.frame.height*0.05 - contentView.spacing).isActive = true
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            searchHistorySuggestion.heightAnchor.constraint(equalToConstant: view.frame.height*0.3),
            searchRealTimeSuggestion.heightAnchor.constraint(equalToConstant: view.frame.height*0.7)
        ])
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        layout()
    }
    
    
    
    
}
