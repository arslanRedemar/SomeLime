//
//  setupAppBaseExt.swift
//  Somlimee
//
//  Created by Chanhee on 2023/12/07.
//

import UIKit

extension UIViewController {
    func initializeVC(){
        self.view.backgroundColor = SomLimeColors.backgroundColor
    }
}

extension UIView {
    func initializeView(){
        self.backgroundColor = SomLimeColors.backgroundColor
    }
}

extension UIScrollView {
    func initializeScrollView(){
        self.backgroundColor = SomLimeColors.backgroundColor
    }
}
extension UITableView {
    func initializeTableView(){
        self.backgroundColor = SomLimeColors.backgroundColor
    }
}


extension UILabel {
    func initializeLabel(){
        self.backgroundColor = SomLimeColors.backgroundColor
        self.font = .hanSansNeoRegular(size: 14)
        self.textColor = SomLimeColors.labelLight
    }
}

extension UITextField {
    func initializeTextField(){
        self.backgroundColor = SomLimeColors.backgroundColor
    }
}
