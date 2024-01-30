//
//  AppConstant.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation
import WebKit

enum  appEnvironment: String{
    case UAT = "uat"
    case FISDOM = "fisdom"
    case MYWAY = "myway"
    case FINITY = "finity"
}

class AppConstant {
    
    static let shared = AppConstant()
    static var delegate: FisdomCallbacks?
    static var isLogin: Bool = false
    static var tokenVerified: Bool = false
    static var loadSecureView: Bool = false
    static var allowForServerRedirect: Bool = false
    static var environment: String = appEnvironment.FISDOM.rawValue
    static var partnerCode: String = ""
    static var WEB_RESULT_SUCCESS = "success"
    static var WEB_RESULT_FAILURE = "failure"
    static var WEB_RESULT_CANCELLED = "cancelled"
    static var RESULT_CANCELED = 0
    static var RESULT_OK = -1
    var partner = Partner()
    static var pingInterval: Double = 60
    static let PLATFORM : String = "ios"
    static let GEN_CALLBACK_VERSION : Int = 3
    static let VERSION_NAME : Int = 167 // need to align this
    static let VERSION_CODE : Int = 167 // need to align this
    static let SDK_VERSION_CODE : Int = 1000
    static let FISDOM_NO_ACTION_URL = "https://fis.do/m/module?action_type=native&native_module=app/do_nothing"
    static let FINITY_NO_ACTION_URL = "https://w-ay.in/m/module?action_type=native&native_module=app/do_nothing"
    static let WAVE2_CLIENT_AUTH = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDdXN0b21lcklkIjoiMTY1MiIsImV4cCI6MTY1ODgxNTIwMCwiaWF0IjoxNjI3Mjc5MjM4fQ.RQowEvYNlk-mIhcaZ3z4ff9Ll3_6I4p8jXqJyhWcjN8"
    var partnerData :Any?
    var user_result :Any?

    // LIVE Backend URLS
//    var serverBaseUrl: String = "https://my.fisdom.com"
    
    // UAT Backend URLS
//    var uatBaseurl: String = "https://sdk-dot-plutus-staging.appspot.com"
    
    // UAT Backend URLS Finserv Bajaj
    var uatBaseurl: String = "https://sdk-dot-plutus-staging.appspot.com"
    var uatBaseEndurl: String = "-dot-plutus-staging.appspot.com"
    
    // LIVE Web OBC URLS
//    var webViewServerBaseUrl: String = "https://obcwebsdk.fisdom.com"
    
    // UAT Web URLS
//    var webViewUatBaseUrl: String = "https://sdk-dot-plutus-web.appspot.com"
    
    // UAT Web URLS Finserv Bajaj
     var webViewUatBaseUrl: String = "https://sdk-dot-plutus-web.appspot.com/#!"
     var webViewUatBaseEndUrl: String = "-dot-plutus-web.appspot.com/#!"
    
    
    static var logOutOnSdkClose: Bool = false
    var PREF_SAVED_HEADER: String = "com.header.auth"
    var PREF_SAVED_SESSION: String = "com.header.session"
    var PREF_BANK_PAYMENT: String = "com.fisdomsdk.payment"
    var PREF_LAST_APP_MINIMIZED_TIME: String = "com.fisdomsdk.PREF_LAST_APP_MINIMIZED_TIME"
    var PREF_INACTIVITY_TIME_OUT: String = "com.fisdomsdk.PREF_INACTIVITY_TIME_OUT"
    
    
    static func setUpWebView(view: FisWkWebView){
        view.allowsBackForwardNavigationGestures = true
        view.allowsLinkPreview = true
        view.isMultipleTouchEnabled = false
       // view.scalesPageToFit = false
    }
    
    func getCompressedData(forImage : UIImage) -> Data? {
        var compression = CGFloat(0.9)
        var data = forImage.jpegData(compressionQuality: compression)
        let maxSize = 500 * 1024
        
        while data != nil && data!.count > maxSize && compression >= 0.1 {
            compression -= CGFloat(0.1)
            data = forImage.jpegData(compressionQuality: compression)
        }
        return data
    }
    
    func convertToBase64new(dataObj: Data) -> String  {
        let strBase64 = dataObj.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    func setAppDelegate(delegate: FisdomCallbacks?)
    {
        AppConstant.delegate = delegate
    }
    
    func getAppDelegate() -> FisdomCallbacks? {
        return AppConstant.delegate
    }
    
    func setLoginStatus(islogin: Bool){
        AppConstant.isLogin = islogin
    }
    
    func getLoginStatus() -> Bool{
        return AppConstant.isLogin
    }

    func setTokenVerified(verify: Bool){
        AppConstant.tokenVerified = verify
    }
    
    func getTokenVerified() -> Bool{
        return AppConstant.tokenVerified
    }
    func setLoadSecureView(value: Bool){
        AppConstant.loadSecureView = value
    }
    
    func getLoadSecureView() -> Bool{
        return AppConstant.loadSecureView
    }
    
    func setAllowForServerRedirect(value: Bool){
         AppConstant.allowForServerRedirect = value
     }
     
     func getAllowForServerRedirect() -> Bool{
         return AppConstant.allowForServerRedirect
     }
    
    
    
    func setLogoutStatus(logout: Bool){
        AppConstant.logOutOnSdkClose = logout
    }
    
    func getLogoutStatus() -> Bool{
        return AppConstant.logOutOnSdkClose
    }
    
    func setPartnerCode(code: String){
        AppConstant.partnerCode = code.lowercased()
    }
    
    func getPartnerCode() -> String{
        return AppConstant.partnerCode
    }
    
    func setAppState(value: String){
        AppConstant.environment = value
    }
    
    func getAppState(value: String)-> String{
        return AppConstant.environment
    }
    
    func preloadWebViewUrl() -> String{
           switch AppConstant.environment {
           case appEnvironment.UAT.rawValue:
//               return "https://sdk-dot-plutus-web.appspot.com/#!/prepare?is_secure=true"
                return "https://app.gaeuat.finwizard.co.in/prepare?is_secure=true"
           case appEnvironment.FISDOM.rawValue:
               return "https://app.fisdom.com/prepare?is_secure=true"
            case appEnvironment.MYWAY.rawValue , appEnvironment.FINITY.rawValue:
               return "https://app.finity.in/prepare?is_secure=true"
           default:
               return "https://" + AppConstant.environment + webViewUatBaseEndUrl + "/prepare?is_secure=true"
           }
       }
    
    func getWebUrl() -> String{
        switch AppConstant.environment {
        case appEnvironment.UAT.rawValue:
//            return "https://sdk-dot-plutus-web.appspot.com/#!/?is_secure=true"
            return "https://app.gaeuat.finwizard.co.in/?is_secure=true"
        case appEnvironment.FISDOM.rawValue:
            return "https://app.fisdom.com/?is_secure=true"
        case appEnvironment.MYWAY.rawValue, appEnvironment.FINITY.rawValue:
            return "https://app.finity.in/?is_secure=true"
        default:
            return "https://" + AppConstant.environment + webViewUatBaseEndUrl + "/?is_secure=true"
        }
    }
    
    func getWebApp2Url() -> String{
        switch AppConstant.environment {
        case appEnvironment.UAT.rawValue:
            return "https://app.gaeuat.finwizard.co.in"
        case appEnvironment.FISDOM.rawValue:
            return "https://app2.fisdom.com"
        case appEnvironment.MYWAY.rawValue, appEnvironment.FINITY.rawValue:
            return "https://app2.finity.in"
        default:
            return "https://" + AppConstant.environment + webViewUatBaseEndUrl
        }
    }
    
    func getModuleWebUrl() -> String{
        switch AppConstant.environment {
        case appEnvironment.UAT.rawValue:
//            return "https://sdk-dot-plutus-web.appspot.com/#!/"
            return "https://app.gaeuat.finwizard.co.in/"
        case appEnvironment.FISDOM.rawValue:
            return "https://app.fisdom.com/"
        case appEnvironment.MYWAY.rawValue , appEnvironment.FINITY.rawValue:
            return "https://app.finity.in/"
        default:
            return "https://" + AppConstant.environment + webViewUatBaseEndUrl
        }
    }
    
    func getBackEndUrl() -> String{
        switch AppConstant.environment {
        case appEnvironment.UAT.rawValue:
//            return "https://sdk-dot-plutus-staging.appspot.com/"
            return "https://my.gaeuat.finwizard.co.in"
        case appEnvironment.FISDOM.rawValue:
            return "https://my.fisdom.com"
        case appEnvironment.MYWAY.rawValue , appEnvironment.FINITY.rawValue:
            return "https://api.finity.in"
        default:
            return "https://" + AppConstant.environment + uatBaseEndurl
        }
    }
    
    func getUserAgent() -> String{
        let osVersion = UIDevice.current.systemVersion as String
        var jsonObject = [String:String]()
        jsonObject["platform"] = "ios"
        jsonObject["version_code"] = AppSettings.versionCode.description
        jsonObject["version_name"] = AppSettings.versionName
        if let webkit = WKWebView().value(forKey: "userAgent") as? String {
            jsonObject["webkit"] = webkit
        }
        jsonObject["osversion"] = osVersion
        jsonObject["mf_only"] = "true"
        jsonObject["model"] = UIDevice.modelName
        jsonObject["deviceid"] = getUUID()
        var userAgent:String = ""
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            // here "jsonData" is the dictionary encoded in JSON data
            userAgent =  String(data: jsonData, encoding: .utf8) ?? ""
//            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            // you can now cast it with the right type
            
//            if let dictFromJSON = decoded as? [String:String] {
//                print(dictFromJSON)
//            }
        } catch {
            print(error.localizedDescription)
        }
        return userAgent
    }
    
    func getJSONString(from dictionary: Any) -> String? {
       if let theJSONData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
         let theJSONText = String(data: theJSONData, encoding: String.Encoding.utf8) {
             return theJSONText
       }
       return nil
    }
}

extension String{
    func isQueryParam() -> Bool {
        if let url1 = URL.init(string: self){
            guard let url = URLComponents(string: url1.absoluteString) else { return false }
            if url.queryItems?.count == 0 || url.queryItems == nil{
                return false
            }
            else{
                return true
            }
        }
        return false
        //        return url1.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
    
    func isQueryContainQuestionMark() -> Bool {
        if self.contains("?"){
            return true
        }
        else{
            return false
        }
    }
    
    func getQueryParams() -> [String: String]? {
        if let url: URL = URL(string: self),
           let queryDict = url.queryParams {
            return queryDict
            
        }
        return nil
    }
    
    mutating func appendQueryString(queryString: String) {
        if self.isQueryContainQuestionMark() {
            self.append("&\(queryString)")
        } else {
            self.append("?\(queryString)")
        }
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }

}
