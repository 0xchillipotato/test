//
//  FisdomSdk.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import MobileCoreServices
//import Wave2SDK
import SDWebImage

open class FisdomSdk: NSObject {
    
    // MARK: - Properties
    private var networkManager = SDKNetworkManager()
    private var sdkToHostPing:Timer?
    private var fisdomServerPing: Timer?
    private var hosttoSdkPing: Timer?
    var partnerCode: String = ""
    private static var maxMissBeatAllowed: Double = 3;
    static var partnerLastBeatTimeStamp:  Double = 0
    private static var sharedFisdomSdk: FisdomSdk = {
        let fisdomSdk = FisdomSdk()
        return fisdomSdk
    }()
    weak var sdkViewController: FSSDKViewController?
    var navigationController: UINavigationController?

    func initNavigationControllerIfNil() {
        if self.navigationController != nil {
            return
        }
        let uiNavigationController = UINavigationController()
        fixiOS15NavBarIssues(navigationBar: uiNavigationController.navigationBar)
        uiNavigationController.setNavigationBarHidden(true, animated: false)
        if #available(iOS 13.0, *) {
            uiNavigationController.modalPresentationStyle = .fullScreen
        } else {
            // Fallback on earlier versions
        }
        self.navigationController = uiNavigationController
    }
    
    @objc public class func shared() -> FisdomSdk {
        return sharedFisdomSdk
    }
    
    private func startPingHandlers() {
        self.sendHeartBeatToHost()
        self.setUpPartnerBeatTimeOut()
        self.setUpFisdomServerPing()
    }
    
    private func stopPingHandler(){
        self.sdkToHostPing?.invalidate()
        self.fisdomServerPing?.invalidate()
        self.hosttoSdkPing?.invalidate()
    }
    
    private func clearCookies() {
        print(#function)
        var fisdomDomain = AppConstant.shared.getBackEndUrl() //uatBaseurl
        let url = URL(string: fisdomDomain)
        guard let host = url?.host else {
            return
        }
        fisdomDomain = host

        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            print("cookies.count = \(cookies.count)")
            for cookie in cookies {
                var cookieDomain = cookie.domain
                if cookieDomain.first == "."{
                    if cookieDomain.count > 1{
                        let index = cookieDomain.index(cookieDomain.endIndex, offsetBy: -(cookieDomain.count - 1))
                        let mySubstring = cookieDomain[index...]
                        cookieDomain = String(mySubstring)
                    }
                }
                if (cookie.name == "plutus-auth" || cookie.name == "plutus-session" || cookie.name == "plutus-2f-auth") && cookieDomain == fisdomDomain {
                    storage.deleteCookie(cookie)
//                    print("plutus cookie is deleted")
                }
            }
        }
        print("cookies.count = \(HTTPCookieStorage.shared.cookies?.count ?? 0)")
    }
    
    @objc public func preloadFisdom(partnerCode: String, environment: String){
        print(#function)
        if !environment.isEmpty {
            AppConstant.shared.setAppState(value: environment.lowercased())
        }
        
        self.networkManager.preloadPartnerConfig(partnerCode: partnerCode) { success, response, msg in
            guard success == .showDataView else {
                print("API failed")
                return
            }
            guard let resultData = response?.response?.result else {
                print("no result data")
                return
            }
            AppSettings.setPartnerSplashLogo(logoUrl: resultData.logoUrl)
            if let decodedImageUrl = resultData.logoUrl.decodeUrlSafely(), let imageUrl = URL(string: decodedImageUrl) {
                SDWebImagePrefetcher.shared.prefetchURLs([imageUrl])
            }
            
        }
    }
    
    func launchSplashScreen() {
        print(#function)
        let storyboardBundle = Bundle(for: SplashScreenViewController.self)
        let storyboard = UIStoryboard(name: "SplashScreen", bundle: storyboardBundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SplashScreenViewController") as? SplashScreenViewController else { return  }
        guard let keyWindow = getKeyWindow() else {
            print("unable to get keyWindow")
            return
        }
        print("keyWindow: \(keyWindow)")
        guard let topViewController = keyWindow.topViewController() else {
            print("unable to fetch topView controller")
            return
        }
        self.initNavigationControllerIfNil()
        if let myNavigationController = self.navigationController {
            myNavigationController.pushViewController(controller, animated: true)
            topViewController.present(myNavigationController, animated: true, completion: nil)
        }
    }
    
    @objc public func startFisdom (customerInfo: [String: Any], partnerCode: String, delegate: FisdomCallbacks?, environment: String ,moduleName :String){
        
        print(#function)
        launchSplashScreen()
        clearCookies()
        // Token is not verified
        AppConstant.shared.setTokenVerified(verify: false)
        
        // Setup Hyperverge sdk
        setupHypervergeSDK()
        UIFontHelper.registerFonts()
        
        // not a secure view (preload)
        AppConstant.shared.setAllowForServerRedirect(value: false)
        
        initializeFisdomSDK(customerInfo: customerInfo, partnerCode: partnerCode, delegate: delegate, environment:environment, moduleName: moduleName)
        print("2fasetup : \(is2faPinSetup())")
//        if !is2faPinSetup(){
//            DispatchQueue.main.async {
//                self.loadSDKViewController(moduleName: moduleName, withUrl: AppConstant.shared.preloadWebViewUrl())
//            }
//        }
    }
    
    @objc public func startFisdom (customerInfo: [String: Any], partnerCode: String, delegate: FisdomCallbacks?, environment: String ){
        
        print(#function)
        launchSplashScreen()
        clearCookies()
        // Token is not verified
        AppConstant.shared.setTokenVerified(verify: false)
                
        // not a secure view (preload)
        AppConstant.shared.setAllowForServerRedirect(value: false)
        
        // Setup Hyperverge sdk
        setupHypervergeSDK()
        UIFontHelper.registerFonts()
        
        initializeFisdomSDK(customerInfo: customerInfo, partnerCode: partnerCode, delegate: delegate, environment:environment, moduleName: "")
        print("2fasetup : \(is2faPinSetup())")
//        if !is2faPinSetup(){
//            DispatchQueue.main.async {
//                self.loadSDKViewController(moduleName: "", withUrl: AppConstant.shared.preloadWebViewUrl())
//            }
//        }
    }
    
    private func initializeFisdomSDK(customerInfo: [String: Any], partnerCode: String, delegate: FisdomCallbacks?, environment: String = "uat" , moduleName: String){
        print(#function)
        AppConstant.shared.setPartnerCode(code: partnerCode)
        AppConstant.shared.setAppDelegate(delegate: delegate)
        AppConstant.shared.setAppState(value: environment.lowercased())
        
        guard #available(iOS 10.0, *) else {
            showAlert()
            return
        }
        
        self.networkManager.loginByToken(partnerCode: partnerCode, customerInfo: customerInfo) { [weak self] ( success, response, msg) in
            
            print("loginByToken API is completed")
            
            switch success {
            case .showDataView:
                switch response?.statuscode {
                case APIStatusCode.ok.rawValue:
                    
                    print("response?.response?.statusCode: \(response?.response?.statusCode)")
                    switch response?.response?.statusCode {
                    case APIStatusCode.ok.rawValue:
                        // Update UI
                        if let viewController = self?.sdkViewController {
                            if viewController.isWaitingForTokenVerification {
                                print("isWaitingForTokenVerification: true")
                                viewController.webViewNavigationFinished()
                            }
                        }
                        if let partnerObj = response?.response?.result?.partner{
                            print("partnerObj: \(partnerObj)")
                            AppConstant.shared.partner = partnerObj
                            AppConstant.shared.setLogoutStatus(logout: partnerObj.logoutOnExit)
                        }
                        if let pingInterval = response?.response?.result?.pingInterval{
                            AppConstant.pingInterval = pingInterval
                        }
                        AppConstant.shared.setLoginStatus(islogin: true)
                        self?.startPingHandlers()
                        if !is2faPinSetup() {
                            // loading webview till we get a clarity whether 2fa is enabled for the user or not
                            DispatchQueue.main.async {
                                self?.loadSDKViewController(moduleName: moduleName, withUrl: AppConstant.shared.preloadWebViewUrl())
                            }
                        } else {
                            self?.open2FAAuthView(flow: .withoutToken, moduleName: moduleName)
                        }
                        break
                    default:
                        // self?.removeSDKViewController()
                        AppConstant.shared.setLoginStatus(islogin: false)
                        delegate?.onInitializationFailed(error: response?.response?.result?.error ?? "Something went wrong");
                        FisdomSdk.shared().dismissView()
                        break
                    }
                    break
                default:
                    delegate?.onInitializationFailed(error: "Connection timed out");
                    FisdomSdk.shared().dismissView()
                    break
                }
                break
            default:
                print("loginBytoken is failed")
                FisdomSdk.shared().dismissView()
                break
            }
        }
    }
    
    private func loadSDKViewController(moduleName: String = "", withUrl : String) {
        print(#function)
        let preloadWebViewUrl =  AppConstant.shared.preloadWebViewUrl()
        let storyboardBundle = Bundle(for: FSSDKViewController.self)
        let storyboard =  UIStoryboard(name: "SDKMain", bundle: storyboardBundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "sdkViewId") as? FSSDKViewController else {
            return
        }
        sdkViewController = controller
        controller.isPayment = false
        controller.moduleName = moduleName
        controller.urlToOpenWebview = withUrl
        if preloadWebViewUrl == withUrl {
            controller.fromFSDKLaunchScreen = true
        }

        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .fullScreen
        } else {
            // Fallback on earlier versions
        }
        
        guard let keyWindow = getKeyWindow() else {
            print("unable to get keyWindow")
            return
        }
        print("keyWindow: \(keyWindow)")
        guard let topViewController = keyWindow.topViewController() else {
            print("unable to fetch topView controller")
            return
        }
        initNavigationControllerIfNil()
        print("topViewController: \(topViewController)")
        if let myNavigationController = self.navigationController {
            print("myNavigationController  \(myNavigationController)")
            myNavigationController.setViewControllers([controller], animated: true)
        }
    }
    
    @objc public func startFisdom() {
        print(#function)
        // Setup Hyperverge sdk
        setupHypervergeSDK()
        
        if (!AppConstant.shared.getLoginStatus() && AppConstant.shared.getAppDelegate() != nil) {
            AppConstant.shared.getAppDelegate()?.onSDKLaunchFailed(error: "Fisdom SDK must be initialized first");
        } else {
            if(AppConstant.shared.getTokenVerified()){
                print("TokenVerified: ")
                AppConstant.shared.setLoadSecureView(value: true)
                print("2fasetup : \(is2faPinSetup())")
                self.startPingHandlers()
                guard !is2faPinSetup() else {
                    self.open2FAAuthView(flow: .withToken, moduleName: "")
                   return
                }
                startSdkView(withUrl: AppConstant.shared.getWebUrl());
            } else {
                print("Token is not verified: ")
                AppConstant.shared.getAppDelegate()?.onSDKLaunchFailed(error: "Fisdom SDK must be initialized first")
            }
        }
    }
    
    @objc public func startFisdom(moduleName: String) {
        print(#function)
        // Setup Hyperverge sdk
        setupHypervergeSDK()
        
        if (!AppConstant.shared.getLoginStatus() && AppConstant.shared.getAppDelegate() != nil) {
            AppConstant.shared.getAppDelegate()?.onSDKLaunchFailed(error: "Fisdom SDK must be initialized first");
        } else {
            if(AppConstant.shared.getTokenVerified()){
                print("TokenVerified: ")
                AppConstant.shared.setLoadSecureView(value: true)
                print("2fasetup : \(is2faPinSetup())")
                self.startPingHandlers()
                guard !is2faPinSetup() else {
                    self.open2FAAuthView(flow: .withToken, moduleName: moduleName)
                   return
                }
                startSdkView(moduleName: moduleName, withUrl: AppConstant.shared.getWebUrl());
            } else {
                print("Token is not verified: ")
                AppConstant.shared.getAppDelegate()?.onSDKLaunchFailed(error: "Fisdom SDK must be initialized first")
            }
        }
    }
   
    private func removeSDKViewController() {
//        if let _ = self.sdkViewController {
//            self.sdkViewController = nil
//        }
    }
    
    private func startSdkView(moduleName: String = "", withUrl : String) {
        print(#function)
        let storyboardBundle = Bundle(for: FSSDKViewController.self)
        let storyboard =  UIStoryboard(name: "SDKMain", bundle: storyboardBundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "sdkViewId") as? FSSDKViewController else {
            print("unable to create ViewController")
            return
        }

        controller.isPayment = false
        controller.moduleName = moduleName
        controller.urlToOpenWebview = withUrl
        guard let keyWindow = getKeyWindow() else {
            print("unable to get keyWindow")
            return
        }
        print("keyWindow: \(keyWindow)")
        guard let topViewController = keyWindow.topViewController() else {
            print("unable to fetch topView controller")
            return
        }
        initNavigationControllerIfNil()
        if let myNavigationController = self.navigationController {
            print("myNavigationController  \(myNavigationController)")
            myNavigationController.setViewControllers([controller], animated: true)
            if (myNavigationController.viewIfLoaded?.window) == nil {                topViewController.present(myNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func open2FAAuthView( flow : TwoFAFlow , moduleName : String){
        print(#function)
        DispatchQueue.main.async {
            let storyboardBundle = Bundle(for: AuthenticationVerificationViewController.self)
            let storyboard = UIStoryboard(name: "Biometic", bundle: storyboardBundle)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "AuthenticationVerificationViewController") as? AuthenticationVerificationViewController else { return  }
            controller.delegateAfterLogin = self
            controller.flow = flow
            controller.forgotFlow = .afterLaunch
            controller.isForceTwoFA = true 
            controller.moduleName = moduleName
            guard let keyWindow = getKeyWindow() else {
                return
            }
            guard let topViewController = keyWindow.topViewController() else {
                print("unable to fetch topView controller")
                return
            }
            self.initNavigationControllerIfNil()
               if let myNavigationController = self.navigationController {
                print("myNavigationController  \(myNavigationController)")
                myNavigationController.setViewControllers([controller], animated: true)
               if (myNavigationController.viewIfLoaded?.window) == nil {
                   topViewController.present(myNavigationController, animated: true, completion: nil)
               }
            }
        }
    }
    
    @objc public func onPaymentCompleted(amount: Double, fisdomTransactionId: String, accountNumber: String, transactionId: String, paymentComplete: Bool) {
        let storyboardBundle = Bundle(for: FSSDKViewController.self)
        let storyboard =  UIStoryboard(name: "SDKMain", bundle: storyboardBundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "sdkViewId") as? FSSDKViewController else {
            print("unable to create ViewController")
            return
        }
        controller.isPayment = true
        var paymentDetail = PaymentDetail()
        paymentDetail.amount = amount
        paymentDetail.accountNumber = accountNumber
        paymentDetail.transactionId = transactionId
        paymentDetail.fisdomTransactionId = fisdomTransactionId
        paymentDetail.paymentComplete = paymentComplete
        controller.paymentDetail = paymentDetail
        guard let keyWindow = getKeyWindow() else {
            print("unable to get keyWindow")
            return
        }
        print("keyWindow: \(keyWindow)")
        guard let topViewController = keyWindow.topViewController() else {
            print("unable to fetch topView controller")
            return
        }
        initNavigationControllerIfNil()
        if let myNavigationController = self.navigationController {
            myNavigationController.pushViewController(controller, animated: true)
            if (myNavigationController.viewIfLoaded?.window) == nil {
                topViewController.present(myNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func onPaymentRequired(paymentDetails: [String: Any]) {
       // killSdk()
        print(#function)

        var fisdomTransactionId: String = ""
        var accountNumber: String = ""
        var amount: Double = 0
        var remark: String = ""
        if let investID = paymentDetails["invest_id"] as? String{
            fisdomTransactionId = investID
        }
        if let value = paymentDetails["account_number"] as? String{
            accountNumber = value
        }
        if let value = paymentDetails["amount"] as? Double{
            amount = value
        }
        // TODO: temparary fix, Should change to JSON format in future
        if let value = paymentDetails["remark"] as? String{
            remark = value
        }else if let remarksDict = paymentDetails["remark"],
            let remarksJSON = AppConstant.shared.getJSONString(from: remarksDict) {
            remark = remarksJSON
        }
        AppConstant.shared.getAppDelegate()?.onPaymentRequired(amount: amount, transactionId: fisdomTransactionId, accountNumber: accountNumber, remark: remark);
    }
    
    func killSdk() {
        if (AppConstant.shared.getAppDelegate() != nil){
            if (AppConstant.shared.getLogoutStatus()) {
                logoutFisdom();
            }
        }
    }
    
    private func sendHeartBeatToHost() {
        self.sdkToHostPing = Timer.scheduledTimer(timeInterval: AppConstant.shared.partner.sdkToHostPingInterval, target: self, selector: #selector(heartBeatToHostCall), userInfo: nil, repeats: true)
        self.sdkToHostPing?.fire()
    }
    
    @objc func heartBeatToHostCall(){
       // print("****************Timer executed heartBeatToHostCall*****************")
        AppConstant.shared.getAppDelegate()?.receiveFisdomHeartBeat(alive: true)
    }
    
    deinit {
        print(#file)
        print(#function)
        self.stopPingHandler()
    }
    
    private func setUpFisdomServerPing() {
        self.fisdomServerPing = Timer.scheduledTimer(timeInterval: AppConstant.pingInterval * 1000, target: self, selector: #selector(fisdomServerCall), userInfo: nil, repeats: true)
        self.fisdomServerPing?.fire()
    }

    @objc func fisdomServerCall(){
        //print("****************Timer executed fisdomServerCall*****************")
        pingFisdomServer()
    }
    
    private func pingFisdomServer() {
        print(#function)
        networkManager.pingFisdomServer { (success, response, msg) in
            print("completed pingFisdomServer()")
            print("success: \(success)")
            print("response: \(response)")
            print("msg: \(msg)")
            switch success{
            case .showDataView:
                switch response?.statuscode{
                case APIStatusCode.loginRequired.rawValue:
                    print("Invalid session")
                    FisdomSdk.shared().sessionTimedOut(reason: "Invalid session")
                    break
                default:
                    break
                }
                break
            default:
                break
            }
        }
    }
    
    func sessionTimedOut(reason: String) {
        print(#function)
        if AppConstant.shared.getAppDelegate() == nil{
            return
        }
        AppConstant.shared.getAppDelegate()?.onFisdomSessionTimedOut(reason: reason);
        self.logoutFisdom()
    }
    
    private func logoutFisdomSession() {
        networkManager.logout { (success, response, msg) in
            print("success: \(success)")
        }
    }
    
    private func partnerBeatExists() -> Bool {
        if (FisdomSdk.partnerLastBeatTimeStamp == 0){
            return true
        }
        
        if ((Double(Date().secondSinc1970) - FisdomSdk.partnerLastBeatTimeStamp)/1000 >= FisdomSdk.maxMissBeatAllowed * AppConstant.shared.partner.hostToSdkPingInterval * 1000) {
            sessionTimedOut(reason: "Partner beat not received");
            return false
        }
        else{
            return true
        }
    }
    
    @objc public func logoutFisdom() {
        if (AppConstant.shared.getLoginStatus()) {
            logoutFisdomSession();
            dismissView()
            AppConstant.shared.setLoginStatus(islogin: false)
            self.closeSDK()
        }
    }
    
    func closeSDK() {
        self.navigationController?.dismiss(animated: true)
        self.navigationController?.removeFromParent()
        self.navigationController?.setViewControllers([], animated: true)
        AppConstant.shared.getAppDelegate()?.onSDKClosed();
        self.stopPingHandler()
    }

    func dismissView() {
        print(#file)
        print(#function)
        DispatchQueue.main.async {
            guard let keyWindow = getKeyWindow() else {
                print("unable to get keyWindow")
                return
            }
            print("keyWindow: \(keyWindow)")
            if let view =  keyWindow.rootViewController?.children.last {
                print("view: \(view)")
                if view.isKind(of: UIViewController.self){
                    view.dismiss(animated: true, completion: nil)
                } else {
                    print("view is not dismissed")
                }
            } else if let view = keyWindow.rootViewController {
                print("root view: \(view)")
                if view.isKind(of: UIViewController.self){
                    view.dismiss(animated: true, completion: nil)
                } else {
                    print("view is not dismissed")
                }
            }
        }
    }


    
    @objc public func sendPartnerHeartBeat(alive: Bool) {
        FisdomSdk.partnerLastBeatTimeStamp = Double(Date().secondSinc1970)
        if (!alive) {
            logoutFisdom();
        }
    }
    
    private func setUpPartnerBeatTimeOut() {
        if (partnerBeatExists()){
            self.hosttoSdkPing = Timer.scheduledTimer(timeInterval: AppConstant.shared.partner.hostToSdkPingInterval, target: self, selector: #selector(heartBeatToSDKCall), userInfo: nil, repeats: true)
            self.hosttoSdkPing?.fire()
        }
    }

    @objc func heartBeatToSDKCall() {
        if (!partnerBeatExists()) {
            self.sessionTimedOut(reason: "Host ping not received \(FisdomSdk.maxMissBeatAllowed) times")
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "", message: "Mutual Fund is available only on iOS-10 or greater.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        guard let keyWindow = getKeyWindow() else {
            print("unable to get keyWindow")
            return
        }
        print("keyWindow: \(keyWindow)")
        guard let topViewController = keyWindow.topViewController() else {
            print("unable to fetch topView controller")
            return
        }
        print("topViewController: \(topViewController)")
        topViewController.present(alertController, animated: true, completion: nil)
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var secondSinc1970: Int{
        return Int((self.timeIntervalSince1970).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension FisdomSdk : TwoFaAuthDelegate{
    func authorisationComplete( flow : TwoFAFlow , moduleName : String) {
        switch flow {
        case .withToken:
            DispatchQueue.main.async {
                self.loadSDKViewController(moduleName: moduleName, withUrl: AppConstant.shared.getWebUrl())
            }
        case .withoutToken:
            DispatchQueue.main.async {
                self.loadSDKViewController(moduleName: moduleName, withUrl: AppConstant.shared.preloadWebViewUrl())
            }
        default:
            DispatchQueue.main.async {
                self.loadSDKViewController(moduleName: moduleName, withUrl: AppConstant.shared.preloadWebViewUrl())
            }
        }
    }
}
