//
//  FisdomCallbackProtocols.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation

@objc public protocol FisdomCallbacks {
    func onInitializationComplete(partner : Any)
    func onInitializationFailed(error: String)
    func receiveFisdomHeartBeat(alive: Bool)
    func onPaymentRequired(amount: Double, transactionId: String, accountNumber: String, remark: String)
    func onSDKLaunchSuccess()
    func onSDKLaunchFailed(error: String)
    func onSDKClosed()
    func onFisdomSessionTimedOut(reason: String)
    func receiveEventCallback(event: [String: Any])
}
