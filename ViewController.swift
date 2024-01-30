//
//  ViewController.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 10/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let networkManager = SDKNetworkManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        FisdomSdk.shared().initializeFisdomSDK(customerInfo: ["token":"5941840993845249"], partnerCode: "lvb", delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func launchSDK(_ sender: Any) {
        FisdomSdk.shared().launchFisdomSDK()
    }
}

extension ViewController: FisdomCallbacks{
    func onInitializationComplete() {
        FisdomSdk.shared().getUserAccountDetails()
    }
    
    func onInitializationFailed(error: String) {
        
    }
    
    func receiveFisdomHeartBeat(alive: Bool) {
        
    }
    
    func onUserDetailsFetchSuccess(userAccountDetails: UserAccountDetails) {
        
    }
    
    func onUserDetalsFetchFailed(error: String) {
        
    }
    
    func onPaymentRequired(amount: Double, transactionId: String, accountNumber: String) {
        
    }
    
    func onSDKLaunchSuccess() {
        
    }
    
    func onSDKLaunchFailed(error: String) {
        
    }
    
    func onSDKClosed() {
        
    }
    
    func onFisdomSessionTimedOut(reason: String) {
        
    }
}
