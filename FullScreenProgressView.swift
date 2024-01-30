//
//  FullScreenProgressView.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 12/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation
import UIKit

class FullScreenProgressView: UIView {
    
    var spinner : CustomSpinnerView
    fileprivate var parentView : UIView?
    var whiteView : UIView?
    
    /// Initialiser to create spinner which will be added over Window
    init() {
        spinner = CustomSpinnerView(frame : CGRect(x: 0, y: 0, width: 80, height: 80))
        parentView = UIApplication.shared.delegate?.window as? UIView
        super.init(frame: UIScreen.main.bounds)
        setupCustomUI()
    }
    
    
    /// Initialiser to create spinner which will be added view of your choice
    ///
    /// - Parameter parent: UIView over which progress view will be added
    init(parent : UIView) {
        spinner = CustomSpinnerView(frame : CGRect(x: 0, y: 0, width: 80, height: 80))
        parentView = parent
        super.init(frame: parent.frame)
        setupCustomUI()
    }
    
    
    /// Internal function to set various UI properties of progress view
    fileprivate func setupCustomUI() {
        self.addSubview(spinner)
        let x = ((parentView?.frame.size.width) ?? 0) / 2.0
        let y = ((parentView?.frame.size.height) ?? 0) / 2.0
        spinner.center = CGPoint(x: x, y : y)
    }
    
    
    /// Invoking this function will show the progress view and start its animation
    func showSpinner() {
        parentView?.addSubview(self)
        parentView?.bringSubviewToFront(self)
        spinner.startAnimating()
    }
    
    func showSpinnerWithWhiteView(y:CGFloat) {
        whiteView = UIView(frame: CGRect(x: 0, y: y, width: self.frame.width, height: self.frame.height - y))
        whiteView?.backgroundColor = UIColor.white
        if whiteView != nil {
            parentView?.addSubview(whiteView!)
        }
        self.showSpinner()
    }
    
    /// Invoking this function will stop animation of progress view and remove it from the view
    func hideSpinner() {
        spinner.stopAnimating()
        if whiteView != nil {
            whiteView?.removeFromSuperview()
            whiteView = nil
        }
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeBackground() {
        spinner.backgroundColor = UIColor.clear
    }
    
}
