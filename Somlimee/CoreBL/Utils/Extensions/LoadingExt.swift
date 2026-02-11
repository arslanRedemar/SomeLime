//
//  UIVC.swift
//  Somlimee
//
//  Created by Chanhee on 2023/08/31.
//

import UIKit

private var loadingViewKey: UInt8 = 0

class LoadingView: UIView {
    
    let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(loadingIndicator)
        self.backgroundColor = SomLimeColors.backgroundColor
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIViewController {
    
    var loadingView: LoadingView? {
        get {
            return objc_getAssociatedObject(self, &loadingViewKey) as? LoadingView
        }
        set {
            objc_setAssociatedObject(self, &loadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    internal func startLoading(){
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
            loadingView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingView!.topAnchor.constraint(equalTo: self.view.topAnchor),
                loadingView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                loadingView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                loadingView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
        print(">>>> LoadingView ON")
    }
    internal func stopLoading(){
        loadingView?.removeFromSuperview()
        loadingView = nil
        print(">>>> LoadingView OFF")
    }
}

extension UIView {
    var loadingView: LoadingView? {
        get {
            return objc_getAssociatedObject(self, &loadingViewKey) as? LoadingView
        }
        set {
            objc_setAssociatedObject(self, &loadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    internal func startLoading(){
        if loadingView == nil {
            loadingView = LoadingView()
            self.addSubview(loadingView!)
            loadingView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingView!.topAnchor.constraint(equalTo: self.topAnchor),
                loadingView!.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                loadingView!.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                loadingView!.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
        }
    }
    internal func stopLoading(){
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}
