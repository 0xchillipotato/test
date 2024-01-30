//
//  CustomSpinnerView.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 12/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation

import UIKit

class CustomSpinnerView: UIView {
    var activityIndicator: UIActivityIndicatorView
    
    override init(frame : CGRect) {
        activityIndicator = UIActivityIndicatorView()
        super.init(frame: frame)
        initialiseSpinner()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initialiseSpinner() {
        backgroundColor = UIColor(white:0x444444, alpha: 0.8)
        clipsToBounds = true
        layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicator.style =
            UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.center = CGPoint(x: frame.size.width / 2,
                                           y: frame.size.height / 2);
        addSubview(activityIndicator)
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
    
}
