//
//  JSInterface.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 15/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol MyExport : JSExport
{
    func check(_ message : String)
    func sayGreeting(_ message: String, _ name: String)
    func anotherSayGreeting(_ message: String, name: String)
    func showDialog(_ title: String, _ message : String)
}

class JSInterface : NSObject, MyExport
{
    func check(_ message: String) {
        print("JS Interface works!")
    }
    
    func sayGreeting(_ message: String, _ name: String)
    {
        print("sayGreeting: \(message): \(name)")
    }
    
    func anotherSayGreeting(_ message: String, name: String)
    {
        print("anotherSayGreeting: \(message): \(name)")
    }
    
    func showDialog(_ title: String, _ message : String)
    {
//        dispatch_async(dispatch_get_main_queue(), {
//            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
//        })
    }
}
