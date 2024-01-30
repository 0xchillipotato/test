    //
//  FisWkWebView.swift
//  Fisdom
//
//  Created by Abhishek Mishra on 15/05/18.
//  Copyright © 2018 finwzard. All rights reserved.
//

import UIKit
import WebKit

enum webRequestType: Int {
    case normalRequest = 0, htmlRequest;
}

class FisWkWebView: WKWebView {
    
    var htmlString: String = ""
    var urlString: String = ""
    var requestType: webRequestType = .normalRequest
    var fisdomDomain: String = ""
    
//    var webConfig: WKWebViewConfiguration
//    var history: WebViewHistory

//    override var backForwardList: WebViewHistory {
//        return history
//    }

    
    
//    init(fram: CGRect, config: WKWebViewConfiguration , history: WebViewHistory) {
//        self.history = history
//        webConfig = config
//        super.init(frame: fram, configuration: webConfig)
//    }
    
    init(frame: CGRect, config: WKWebViewConfiguration ) {
//        webConfig = config
        super.init(frame: frame, configuration: config)
    }
    
    deinit {
        print(#file)
        print(#function)
        self.configuration.userContentController.removeScriptMessageHandler(forName: "callbackNative")
    }
    
    required init?(coder: NSCoder) {
//        if let history = coder.decodeObject(forKey: "history") as? WebViewHistory {
//            self.history = history
//        }
//        else {
//            history = WebViewHistory()
//        }
        fatalError("init(coder:) has not been implemented")
    }
//
//    override func encode(with aCoder: NSCoder) {
//        super.encode(with: aCoder)
//        aCoder.encode(history, forKey: "history")
//    }
    
//    func setRequest() {
//        print(#function)
//        print("urlString: \(urlString)")
//        var isAuthCookieAdded = false
//        var isSessionCookieAdded = false
//
//        var cookieStr: String = ""
//        fisdomDomain = AppConstant.shared.getBackEndUrl() //uatBaseurl
//        let url = URL(string: fisdomDomain)
//        fisdomDomain = (url?.host)!
//        print("fisdomDomain: \(fisdomDomain)")
//        self.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
//        self.configuration.preferences.javaScriptEnabled = true
//        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
//
//        if #available(iOS 11.0, *) {
//            let cookieStore = self.configuration.websiteDataStore.httpCookieStore
//
//            if !AppConstant.shared.getTokenVerified() &&
//                self.urlString.contains(AppConstant.shared.preloadWebViewUrl()) {
//                // without cookies, we should only load 'preloadWebURL'
//                print("loading preloadWebViewUrl")
//                if let myURL = URL(string: self.urlString) {
//                    let myRequest = URLRequest(url: myURL)
//                    self.loadRequest(req: myRequest)
//                    return
//                }
//                return
//            } else {
//                if let cookies = HTTPCookieStorage.shared.cookies {
//                    print("************* SET REQUEST**********")
//                    print("cookies.count = \(cookies.count)")
//
//                    if cookies.count > 0 {
//                        for cookie in cookies {
//
//                            var cookieDomain = cookie.domain
//                            if cookieDomain.first == "."{
//                                if cookieDomain.count > 1{
//                                    let index = cookieDomain.index(cookieDomain.endIndex, offsetBy: -(cookieDomain.count - 1))
//                                    let mySubstring = cookieDomain[index...]
//                                    cookieDomain = String(mySubstring)
//                                }
//                            }
//                            if cookieDomain == fisdomDomain {
//                                print("***********")
//                                print("cookie: \(cookie)")
//                                print("***********")
//                                if cookie.name == "plutus-auth" {
//                                    if let myURL = URL(string: self.urlString) {
//                                        let myRequest = URLRequest(url: myURL)
//                                        cookieStore.setCookie(cookie, completionHandler:{ [weak self] in
//                                            print("plutus-auth cookie is set")
//                                            isAuthCookieAdded = true
//                                            if isAuthCookieAdded && isSessionCookieAdded {
//                                                self?.loadRequest(req: myRequest)
//                                            }
//                                        })
//                                    } else {
//                                        self.loadHTMLString(self.htmlString, baseURL: nil)
//                                    }
//                                }
//                                else if cookie.name == "plutus-session" {
//                                    if let myURL = URL(string: self.urlString) {
//                                        let myRequest = URLRequest(url: myURL)
//                                        cookieStore.setCookie(cookie, completionHandler:{ [weak self] in
//                                            print("plutus-session cookie is set")
//                                            isSessionCookieAdded = true
//                                            if isAuthCookieAdded && isSessionCookieAdded {
//                                                self?.loadRequest(req: myRequest)
//                                            }
//                                        })
//                                    } else {
//                                        self.loadHTMLString(self.htmlString, baseURL: nil)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            if let cookies = HTTPCookieStorage.shared.cookies {
//                for cookie in cookies {
//                    //print(cookie)
//                    cookieStr = ""
//                    if cookie.name == "plutus-auth" && cookie.domain == fisdomDomain{
//                        let domain = "domain=" + cookie.domain + ";"
//                        let Path = "path=" + cookie.path + ";"
//                        let name = "name=" + cookie.name + ";"
//                        let val = "value=" + cookie.value
//                        cookieStr = domain + Path + name + val
//                        break
//                    }
//                }
//            }
//
//            if let myURL = URL(string: self.urlString){
//                var myRequest = URLRequest(url: myURL)
//                myRequest.addValue(cookieStr, forHTTPHeaderField: "Set-Cookie")
//                loadRequest(req: myRequest)
//            }
//            else
//            {
//                loadHTMLString(htmlString, baseURL: nil)
//            }
//        }
//    }
    
    func loadRequest(req: URLRequest){
        print(#function)
        print("req.url: \(req.url)")
        let request = req
        switch self.requestType.rawValue{
        case 0:
            self.load(request)
            break
        case 1:
            self.loadHTMLString(self.htmlString, baseURL: request.url)
            break
        default:
            break
        }
    }
    
    func fetchDataRecords(ofTypes dataTypes: Set<String>,
                          completionHandler: @escaping ([WKWebsiteDataRecord]) -> Void){
        //print(dataTypes)
        
    }

}

    
extension WKWebViewConfiguration {
    /// Async Factory method to acquire WKWebViewConfigurations packaged with system cookies
    static func cookiesIncluded(completion: @escaping (WKWebViewConfiguration) -> Void) {
        print(#function)
        let config = WKWebViewConfiguration()
        let processPool = WKProcessPool()
        config.processPool = processPool
        config.preferences.javaScriptEnabled = true

        guard let cookies = HTTPCookieStorage.shared.cookies else {
            print("no cookies")
            completion(config)
            return
        }
        var fisdomDomain: String = ""
        fisdomDomain = AppConstant.shared.getBackEndUrl() //uatBaseurl
        let url = URL(string: fisdomDomain)
        fisdomDomain = url?.host ??  "my.fisdom.com"
        
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let waitGroup = DispatchGroup()
        for cookie in cookies {
//            print(cookie)
            var cookieDomain = cookie.domain
            if cookieDomain.first == "."{
                if cookieDomain.count > 1{
                    let index = cookieDomain.index(cookieDomain.endIndex, offsetBy: -(cookieDomain.count - 1))
                    let mySubstring = cookieDomain[index...]
                    cookieDomain = String(mySubstring)
                }
            }
            if cookieDomain == fisdomDomain, (cookie.name == "plutus-auth" || cookie.name == "plutus-session" || cookie.name == "plutus-2f-auth") {
                waitGroup.enter()
                print("enter!!")
                if #available(iOS 11.0, *) {
                    dataStore.httpCookieStore.setCookie(cookie) {
                        print("leave!!")
                        waitGroup.leave()
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        waitGroup.notify(queue: DispatchQueue.main) {
            print("DONE!!")
            config.websiteDataStore = dataStore
            completion(config)
        }
    }
}
    
    extension WKWebView {
        func clean() {            
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                    #endif
                }
            }
        }
    }
