//
//  FSSDKViewController.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 12/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import UIKit
import WebKit
import Foundation
import MobileCoreServices
import Photos
import HyperSnapSDK
import CoreLocation

//Callback
typealias ViewCallback = (_ val : String, _ message: String) -> Void

class FSSDKViewController: UIViewController{
    
    var callback: ViewCallback?
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBAction func backBtnPressed(_ sender: Any) {
        onBackPresssed()
    }
    
    //@IBOutlet weak var webView: FisWkWebView!
    weak var webView: FisWkWebView?
    @IBOutlet weak var NavigationBarView: UIView!
    weak var spinnerView : FullScreenProgressView?
    var isPayment: Bool = false
    var isEquityPayment: Bool = false
    //    weak var obj: FisWkWebView?
    var imageFileName: String = ""
    var takeControl: Int = 0
    var docType: docType = .image
    var thirdPartyArguments: [String: Any] = [:]
    var videoData: Data?
    var dialogObj: DialogObj?
    var wasCustomSet: Bool = false
    var paymentDetail: PaymentDetail?
    var jsonStringOfUser : String = ""
    var moduleName: String = ""
    var urlToOpenWebview : String = ""
    var requestedCode : String = ""
    
    var backUrl : String = ""
    var backText: String = ""
    var isCallBackToWeb: Bool = false
    var backTopBarStatus: Bool = false
    var webConfig: WKWebViewConfiguration {
        get {
            let webCfg = WKWebViewConfiguration()
            let userController = WKUserContentController()
            userController.add(self, name: "callbackNative")
            webCfg.userContentController = userController;
            return webCfg;
        }
    }
    var isWaitingForTokenVerification = false
    
    // Hyperverge
    var checkLiveness = false
    var isLive: String = ""
    var livenessScore: String = ""
    var locationService: GeolocationService?
    var fromFSDKLaunchScreen: Bool = false
    
    deinit {
        print(#file)
        print(#function)
        self.webView?.stopLoading()
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackNative")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        progressIndicator.isHidden = true
        //         Do any additional setup after loading the view.
        NavigationBarView.backgroundColor = UIColor.clear
        setUpWebView()
        locationService?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        print(#function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        print(#function)
    }
    
    func setcallback(_ callback: @escaping ViewCallback){
        self.callback = callback
    }
    
    private func getwebViewConfig() -> WKWebViewConfiguration {
        print(#function)
        let webCfg = WKWebViewConfiguration()
        let processPool = WKProcessPool()
        webCfg.processPool = processPool
        webCfg.preferences.javaScriptEnabled = true
        let controller = WKUserContentController()
        controller.add(CustomWKScriptMessageHandler(delegate: self), name: "callbackNative")
        webCfg.userContentController = controller
        return webCfg
    }
    
    private func setUpWebView(){
        
        print(#function)
        UserDefaults.standard.unregister(defaultsFor: "UserAgent")
        var webUrl = ""
        if (self.isCallBackToWeb){
            webUrl = self.backUrl
        }else{
            if !isPayment{
                if(AppConstant.shared.getLoadSecureView()){
                    webUrl = urlToOpenWebview
                    if moduleName != ""{
                        webUrl = AppConstant.shared.getModuleWebUrl() + moduleName
                        webUrl.appendQueryString(queryString: "is_secure=true")
                    }
                } else {
                    webUrl = urlToOpenWebview
                }
            } else {
                isPayment = false
                if let paymnetObj = UserDefaults.standard.value(forKey: AppConstant.shared.PREF_BANK_PAYMENT) as? [String: Any]{
                    var data: [String: Any] = [:]
                    if let value = paymnetObj["data"] as? [String: Any]{
                        data = value
                        data["amount"] = paymentDetail?.amount
                        data["invest_id"] =  paymentDetail?.fisdomTransactionId
                        data["transactionId"] = paymentDetail?.transactionId
                        data["account_number"] = paymentDetail?.accountNumber
                        data["paymnentstatus"] = paymentDetail?.paymentComplete
                    }
                    if let redirectUrl = paymnetObj["redirect_url"] as? String{
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let jsonString = String(data: jsonData, encoding: .utf8)!
                            if let encodedstring =
                                jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                                if redirectUrl.decodeUrl().isQueryContainQuestionMark(){
                                    webUrl = redirectUrl.decodeUrl() + "&data=" + encodedstring
                                }
                                else{
                                    webUrl = redirectUrl.decodeUrl() + "?data=" + encodedstring
                                }
                            }
                        }
                        catch{
                            print("Error In Url")
                        }
                    }
                }
            }
        }
        WKWebViewConfiguration.cookiesIncluded { (configuration) in
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let viewFrame: CGRect = CGRect.init(x: self.view.frame.origin.x, y: statusBarHeight, width: self.view.bounds.size.width, height: self.view.bounds.size.height - statusBarHeight)

            let controller = WKUserContentController()
//            controller.add(CustomWKScriptMessageHandler(delegate: self), name: "callbackNative")
            controller.add(self, name: "callbackNative")
            configuration.userContentController = controller
            if self.webView == nil {
                let wkWebView = FisWkWebView.init(frame: viewFrame, config: configuration)
                self.webView = wkWebView
                self.view.addSubview(self.webView!)
                self.configureWebView(self.webView, webUrl: webUrl)

            } else {
                self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackNative")
                self.webView?.removeFromSuperview()
                let wkWebView = FisWkWebView.init(frame: viewFrame, config: configuration)
                self.webView = wkWebView
                self.view.addSubview(self.webView!)
                self.configureWebView(self.webView, webUrl: webUrl)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("FSSDKViewController: didReceiveMemoryWarning")
    }
    
    func configureWebView(_ webView: FisWkWebView?, webUrl: String) {
        print(#function)
        webView?.urlString = webUrl
        webView?.isHidden = true
        webView?.requestType = .normalRequest
        webView?.allowsLinkPreview = true
        webView?.isMultipleTouchEnabled = false
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        webView?.scrollView.bounces = false
        webView?.allowsBackForwardNavigationGestures = false
        webView?.contentMode = .scaleToFill
        if let myURL = URL(string: webUrl) {
            let myRequest = URLRequest(url: myURL)
            webView?.loadRequest(req: myRequest)
        }
    }
    
    func showSpinner() {
        DispatchQueue.main.async {
            DataLoadingView.shared().showLoader()
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            DataLoadingView.shared().hideLoader()
        }
    }

    func showPopUp() {
        print(#function)
        if let dialogJson  = thirdPartyArguments["dialog"] as? [String: Any]{
            dialogObj = DialogObj.init(obj: dialogJson)
            let alertController = UIAlertController(title: "", message: dialogObj?.message, preferredStyle: .alert)
            var okayAction: UIAlertAction?
            var cancelAction: UIAlertAction?
            if (dialogObj?.actionArr.count)! > 1{
                // Create the actions
                okayAction = UIAlertAction(title: dialogObj?.actionArr[0].actionText, style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    if self.dialogObj?.actionArr[0].redirectUrl != "" {
                        self.manageToolBar(isShowToolBar: false)
                        self.setUseragent()
                        if let urlStr = self.dialogObj?.actionArr[0].redirectUrl.decodeUrlSafely(), let url = URL(string: urlStr)  {
                            self.webView?.load(URLRequest.init(url: url))
                            self.takeControl = 0;
                        }
                    }
                }
                alertController.addAction(okayAction!)
                cancelAction = UIAlertAction(title: dialogObj?.actionArr[1].actionText, style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    if self.dialogObj?.actionArr[1].redirectUrl != "" {
                        self.manageToolBar(isShowToolBar: false)
                        self.setUseragent()
                        if let urlStr = self.dialogObj?.actionArr[1].redirectUrl.decodeUrlSafely(), let url = URL(string: urlStr)  {
                            self.webView?.load(URLRequest.init(url: url))
                            self.takeControl = 0;
                        }
                    }
                }
                alertController.addAction(cancelAction!)
            }
            else if dialogObj?.actionArr.count == 1{
                okayAction = UIAlertAction(title: dialogObj?.actionArr[0].actionText, style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    if self.dialogObj?.actionArr[0].redirectUrl != "" {
                        self.manageToolBar(isShowToolBar: false)
                        self.setUseragent()
                        if let urlStr = self.dialogObj?.actionArr[0].redirectUrl.decodeUrlSafely(), let url = URL(string: urlStr)  {
                            self.webView?.load(URLRequest.init(url: url))
                            self.takeControl = 0;
                        }
                    }
                }
                alertController.addAction(okayAction!)
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onBackPresssed(){
        print(#function)
        FisdomSdk.partnerLastBeatTimeStamp = Double(Date().secondSinc1970)
        switch takeControl {
        case 1:
            print("isCallBackToWeb: \(isCallBackToWeb)")
            if isCallBackToWeb{
                showBackAlert()
            }
            //          FisdomSdk.shared().killSdk()
            break
        case 2:
            showPopUp()
            break
        default:
            print("evaluateJavaScript")
            webView?.evaluateJavaScript("callbackWeb.back_pressed()", completionHandler: nil)
            break
        }
    }
    
    func resetValue(){
        self.backUrl = ""
        self.backText = ""
        self.isCallBackToWeb = false
    }
    
    func showBackAlert() {
        print(#function)
        print("self.backText = \(self.backText)")
        if(self.backText == ""){
            self.loadUrlInExistingWebview(url : self.backUrl)
        }else{
            let alertController = UIAlertController(title: nil, message: self.backText, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.loadUrlInExistingWebview(url : self.backUrl)
            }
            alertController.addAction(okayAction)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) {
                UIAlertAction in
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func loadUrlInExistingWebview(url : String){
        print(#function)
        self.manageToolBar(isShowToolBar: false)
        if let myURL = URL(string: url) {
            let myRequest = URLRequest(url: myURL)
            webView?.loadRequest(req: myRequest)
        }
    }
    
    func locationDenied() {
        DispatchQueue.main.async
            {
                var alertText = Constants.LOCATION_OFF_ALERT
                var alertButton = "OK"
                var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString),  UIApplication.shared.canOpenURL(settingsUrl) {
                    alertText =  Constants.LOCATION_OFF_ALERT_GO
                    alertButton = "Go"
                    goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        }
                    })
                }
            showAlertWithMultipleActions(alertText: alertText, goAction: goAction, title: "Error")
        }
    }
    
    
    func sendLocation( location : GeoLocation? = nil , permissionAllowed : Bool){
        let locationDict : [String: Any] = ["lat" : location?.latitude ?? 0.0 , "lng" : location?.longitude ?? 0.0 ]
        var uploadDict: [String: Any] = ["location": locationDict ,"nsp": carrierName() , "device_id" : getUUID()]
        if (!permissionAllowed){
            uploadDict["location_permission_denied"] = true
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: uploadDict, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                debugPrint("obj : \(jsonString)")
                let method = "callbackWeb.send_device_data(\(jsonString))"
                webView?.evaluateJavaScript(method) { (value, error) in
                    //print(error)
                }
            } else {
                NSLog("failed to send location data, data is empty")
            }
            
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func showErrorDialog() {
        
    }
    
}

extension FSSDKViewController : WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        print(#function)
        self.webView = webView as? FisWkWebView
        showSpinner()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        self.webView = webView as? FisWkWebView
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        self.webView = webView as? FisWkWebView
        completionHandler(.performDefaultHandling, nil)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
        print(#function)
        self.webView = webView as? FisWkWebView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print(#function)
        self.webView = webView as? FisWkWebView
        webViewNavigationFinished()
    }
    
    func webViewNavigationFinished() {
        print(#function)
        print("getAllowForServerRedirect: \(AppConstant.shared.getAllowForServerRedirect())")
        if !AppConstant.shared.getAllowForServerRedirect() {
            if(AppConstant.shared.getTokenVerified() ){
                print("token verified:")
                WebViewLoadComplete()
            }else{
                print("waiting for token verification")
                isWaitingForTokenVerification = true
            }
        } else {
            AppConstant.shared.getAppDelegate()?.onSDKLaunchSuccess()
            self.webView?.isHidden = false
            fromFSDKLaunchScreen = false
            hideSpinner()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        print(#function)
        if (error.localizedDescription == "The operation couldn’t be completed. (NSURLErrorDomain error -999.)" ){
            //            redirection error
        } else{
            AppConstant.shared.getAppDelegate()?.onSDKLaunchFailed(error: "error in initialization of sdk")
        }
        hideSpinner()
        self.webView = webView as? FisWkWebView
        // self.dismissCampaign(code: "400", message: "Something went wrong! Please try again after some time.")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        print(#function)
        debugPrint("error: \(error)")
        hideSpinner()
    }
    
    func showAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: "Are you sure you want to exit the application process?", preferredStyle: .alert)
        // Create the actions
        let okayAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.showInvestHome()
        }
        alertController.addAction(okayAction)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) {
            UIAlertAction in
            //Don't do anything.
        }
        alertController.addAction(cancelAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showInvestHome(){
    }
    
    func WebViewLoadComplete(){
        print(#function)
        
        AppConstant.shared.setAllowForServerRedirect(value: true)
        prepareUserDataJSON()
        submitUserData(data: jsonStringOfUser)
        loadFisdomWebUrl()
        
        self.webView?.isHidden = false
        AppConstant.shared.getAppDelegate()?.onSDKLaunchSuccess();
        AppConstant.shared.getAppDelegate()?.onInitializationComplete(partner: AppConstant.shared.partnerData!)
        isWaitingForTokenVerification = false
        
        if !fromFSDKLaunchScreen {
            hideSpinner()
        }
        
        guard let webView = self.webView else {
            return
        }
        if #available(iOS 11.0, *) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
                print("got cookies inside webview")
                for cookie in cookies {
                    print("******")
                    print(cookie)
                    print("######")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func submitUserData(data : String) {
        print(#function)
        let method = "callbackWeb.return_data(\(data))"
        webView?.evaluateJavaScript(method) { (value, error) in
            print("error: \(String(describing: error))")
            print("value: \(String(describing: value))")
        }
    }
    
    func prepareReturnDataJson() -> String{
        print(#function)
        let uploadDict: [String: Any] = ["partner": AppConstant.shared.getPartnerCode(),
                                         "sdk_version_code" : AppConstant.VERSION_CODE ,
                                         "sdk_version_name" : AppConstant.VERSION_NAME ,
                                         "callback_version" : AppConstant.GEN_CALLBACK_VERSION ,
                                         "platform" : AppConstant.PLATFORM,
                                         "ios_sdk_version_code" :  AppConstant.SDK_VERSION_CODE
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: uploadDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)!
            return jsonString
        } catch let e {
            print("exception: \(e.localizedDescription)")
            return ""
        }
    }
    
    func prepareUserDataJSON() {
        print(#function)
        let uploadDict: [String: Any] = ["partner": AppConstant.shared.getPartnerCode(),
                                         "user_data": AppConstant.shared.user_result ?? "" ,
                                         "sdk_version_code" : AppConstant.VERSION_CODE ,
                                         "sdk_version_name" : AppConstant.VERSION_NAME ,
                                         "callback_version" : AppConstant.GEN_CALLBACK_VERSION ,
                                         "platform" : AppConstant.PLATFORM,
                                         "ios_sdk_version_code" :  AppConstant.SDK_VERSION_CODE
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: uploadDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)!
            self.jsonStringOfUser = jsonString
        } catch let e {
            print("exception: \(e.localizedDescription)")
        }
    }
    
    func loadFisdomWebUrl() {
        print(#function)
        self.urlToOpenWebview = AppConstant.shared.getWebUrl()
        if self.moduleName != ""{
            self.urlToOpenWebview = AppConstant.shared.getModuleWebUrl() + self.moduleName
            self.urlToOpenWebview.appendQueryString(queryString: "is_secure=true")
        }
        //        let url = URL(string : self.urlToOpenWebview )!
        //        self.webView?.load(URLRequest(url: url))
        
        // Dont remove following code
        self.webView?.urlString = self.urlToOpenWebview
//        self.webView?.setRequest()
        print("urlToOpenWebview: \(self.urlToOpenWebview)")
        self.setUpWebView()
//        if let myURL = URL(string: self.urlToOpenWebview) {
//            let myRequest = URLRequest(url: myURL)
//            webView?.loadRequest(req: myRequest)
//        }
    }
}

extension FSSDKViewController : WKScriptMessageHandler{

    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: "We Would Like To Access the Camera", message: Constants.CAMERA_OFF_ALERT, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
                            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(appSettingsURL as URL, options: [:], completionHandler: nil)
                                }
                            }})
        self.present(alert, animated: true, completion: nil)
    }
     
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
//
//           if let url = navigationAction.request.url {
//                   print(url.absoluteString)
//                   if url.absoluteString.hasPrefix("https://example.com"){
//                       print("SUCCESS")
//                }
//           }
//
//           decisionHandler(.allow)
        var message = ""
        guard isEquityPayment else {
            debugPrint("not equity payment, decisionHandler(.allow)")
            decisionHandler(.allow)
            return
        }
        guard let urlStr = navigationAction.request.url?.absoluteString else {
            //                dismissProgressAync()
            decisionHandler(.allow)
            return
        }
        if urlStr.contains(Constants.EQUITY_PAYMENT_URL_SUCCESS) {
            debugPrint("equity payment success")
//                dismissProgressAync()
            self.navigationController?.popViewController(animated: false)
            if let queryDist = urlStr.getQueryParams() {
                if let messageString = queryDist["message"] {
                    message = messageString
                }
            }
            callback?(EquityPaymentActions.COMPLETE.rawValue, message)
//                return false
            decisionHandler(.cancel)
        } else if urlStr.contains(Constants.EQUITY_PAYMENT_URL_FAILED) {
            debugPrint("equity payment failed")
//                dismissProgressAync()
            self.navigationController?.popViewController(animated: false)
            if let queryDist = urlStr.getQueryParams() {
                if let messageString = queryDist["message"] {
                    message = messageString
                }
            }
            callback?(EquityPaymentActions.FAILED.rawValue, message)
            decisionHandler(.cancel)
        } else {
//                return true
            //                dismissProgressAync()
            debugPrint("not equity payment, decisionHandler(.allow)")
            decisionHandler(.allow)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(#function)
        print("message: \(message)")
        if let messageBody = message.body as? [String: Any] {
            print("messageBody:\(messageBody)")
            if let action = messageBody["action"] as? String{
                print("action: \(action)")
                switch action{
                case "login":
                    break
                case "get_partner_code":
                    let code: String = AppConstant.shared.getPartnerCode()
                    webView?.evaluateJavaScript("callbackWeb.set_partner_code(\'\(code)\')"){ (value, error) in
                        //print(error)
                    }
                    break
                case "take_back_button_control":
                    changeTakeControllerStatus()
                    if let data = messageBody["action_data"] as? [String: Any]{
                        self.isCallBackToWeb = true
                        if let text = data["message"] as? String{
                            self.backText = text
                        }
                        if let url = data["url"] as? String{
                            self.backUrl = url
                        }
                        if let backTopBarStatus = data["show_top_bar"] as? Bool{
                            self.backTopBarStatus = backTopBarStatus
                            self.manageToolBar(isShowToolBar: backTopBarStatus)
                        }
                    }
                    else{
                        self.manageToolBar(isShowToolBar: false)
                        self.navigationController?.popViewController(animated: false)
                    }
                    break
                case "reset_back_button_control":
                    self.resetValue()
                    break
                case "exit_web":
                    if isEquityPayment {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        userExit()
                    }
                    break
                case "clear_history":
                    //                  clearHistory()
                    break
                case "take_picture":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let checkLiveness = data["check_liveness"] as? Int, checkLiveness == 1 {
                            if let fileName = data["file_name"] as? String{
                                imageFileName = fileName
                            }
                            self.launchHypervergeSDK()
                        } else if let fileName = data["file_name"] as? String{
                            imageFileName = fileName
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
                                switch authStatus {
                                case .authorized:
                                    self.openCamera()
                                case .denied:
                                    alertPromptToAllowCameraAccessViaSettings()
                                default:
                                    self.openCamera()
                                }
                            } else {
                                let alertController = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                                })
                                alertController.addAction(defaultAction)
                                present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    break
                case "pick_picture":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let fileName = data["file_name"] as? String{
                            imageFileName = fileName
                            self.openGallery()
                        }
                    }
                    break
                case "open_canvas":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let fileName = data["file_name"] as? String{
                            imageFileName = fileName
                            let storyboardBundle = Bundle(for: SignatureController.self)
                            let vc = SignatureController.init(nibName: "SignatureController", bundle: storyboardBundle)
                            vc.delegate = self
                            if #available(iOS 13.0, *) {
                                vc.modalPresentationStyle = .fullScreen
                            } else {
                                // Fallback on earlier versions
                            }
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    break
                case "take_video":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let fileName = data["file_name"] as? String{
                            imageFileName = fileName
                            videoLibrary()
                        }
                    }
                    break
                case "third_party_redirect":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        thirdPartyRedirect(arguments: data)
                    }
                    break
                case "make_bank_payment":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        makeBankPayment(arguments: data)
                        self.dismiss(animated: true, completion: nil)
                    }
                    break
                case "show_top_bar":
                    manageToolBar(isShowToolBar: true)
                    break
                case "hide_top_bar":
                    manageToolBar(isShowToolBar: false)
                    break
                case "session_expired":
                    FisdomSdk.shared().logoutFisdom()
                    break
                case "native_back":
                    print("native back")
                    setUpWebView()
                    break
                case "share_text":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let message = data["message"] as? String{
                            let textToShare: String = message
                            let objectsToShare = [textToShare] as [Any]
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            //New Excluded Activities Code
                            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                            activityVC.popoverPresentationController?.sourceView = self.view
                            activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                            }
                            //   TODO: iOS 13 presentation handling
                            
                            self.present(activityVC, animated: true, completion: nil)
                        }
                    }
                    break
                case "open_browser":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let url = data["url"] as? String{
                            if let url = URL.init(string: url){
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    break
                    
                case "get_blob":
                    guard let data = messageBody["action_data"] as? [String: Any] else {
                        return
                    }
                    guard let fileName = data["file_name"] as? String , let mimeTypes = data["mime_types"] as? [String] ,   mimeTypes.count > 0 else {
                        return
                    }
                    imageFileName = fileName
                    self.openDocumentPicker(with: mimeTypes)
                    break
                case "event_callback":
                    if let data = messageBody["action_data"] as? [String: Any]{
                        AppConstant.shared.getAppDelegate()?.receiveEventCallback(event: data)
                    }
                    break
                case "reload":
                    webView?.reload()
                    break
                case "clear_cache":// implemented but not tested
                    webView?.clean()
                    break
                case "open_url": // implemented but not tested
                    isCallBackToWeb = false
                    guard let data = messageBody["action_data"] as? [String: Any] else {
                        return
                    }
                    guard let url = data["url"] as? String else {
                        return
                    }
                    loadUrlInExistingWebview(url: url)
                    break
                case "native_intent": // implemented but not tested
                    guard let data = messageBody["action_data"] as? [String: Any] else {
                        return
                    }
                    nativeIntent(intentDetails: data)
                    break
                case "get_data": // implemented but not tested
                    let obj = prepareReturnDataJson()
                    submitUserData(data: obj)
                    break
                case "2fa_module": // implemented but not tested
                    guard let data = messageBody["action_data"] as? [String: Any] else {
                        return
                    }
                    if let requestCode = data["request_code"] as? String {
                        self.requestedCode = requestCode
//                        print(requestCode)
                    }
                    if let operation = data["operation"] as? String {
                        print(operation)
                        switch operation {
                        case "reset_pin":
                            moveToResetPinView(delegate: self)
                        case "setup_pin":
                            moveToPinSetupView(flow: .setPin, delegate: self)
                        default:
                            moveToPinSetupView(delegate: self)
                        }
                    }
                    break
                case "2fa_expired": // implemented but not tested
                    if let data = messageBody["action_data"] as? [String: Any]{
                        if let requestCode = data["request_code"] as? String {
                            self.requestedCode = requestCode
                            print(requestCode)
                        }
                    }
                    open2FAAuth(viewControllerToPresent: self, delegate: self)
                    // send back to  web sendResultToWeb
                    break
                case "get_device_data":
                    locationService = GeolocationService(delegate: self)
                    break
                case "show_toast" , "show_info_dialog" , "show_snack" , "set_user_agent" , "reset_user_agent" , "restart_web" , "set_web_interface":
                    debugPrint("not handled")
                    // need to check whether required or not , implemented in android gweb
                    break
                case "download_on_device" , "get_pdf" :
                    debugPrint("not handled")
                    // implemented in android gweb but pdf download is not supported
                    break
                case "open_module", "restart_module" , "exit_module", "on_cancelled":
                    // not required in sdk as of now
                    debugPrint("not handled")
                    break
                case "on_success":
//                    dismissProgressAync()
                    self.navigationController?.popViewController(animated: false)
                    callback?(EquityPaymentActions.COMPLETE.rawValue, "")
                case "on_failure":
//                    dismissProgressAync()
                    self.navigationController?.popViewController(animated: false)
                    callback?(EquityPaymentActions.FAILED.rawValue, "")
                case "open_equity":
                        //Open Equity
                    break
                default:
                    break
                }
            }
        }
    }
}

extension FSSDKViewController : WKUIDelegate{
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        print(#function)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "OK Button")
        let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true)
        completionHandler()
    }
}

extension FSSDKViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension FSSDKViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if imageFileName == "ipvvideo"{
            if #available(iOS 11.0, *) {
                if let url  = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                    do {
                        videoData = try Data.init(contentsOf: url)
                        uploadImage(image: UIImage())
                    }
                    catch{
                    }
                }
            } else {
                if let url  = info[UIImagePickerController.InfoKey.referenceURL] as? URL{
                    do {
                        videoData = try Data.init(contentsOf: url)
                        uploadImage(image: UIImage())
                    }
                    catch{
                    }
                }
            }
        }
        else{
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                uploadImage(image: image)
            }
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: {})
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            docType = .image
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //            print("galary")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            docType = .image
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func videoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.videoMaximumDuration = 25
            imagePicker.cameraCaptureMode = .video
            docType = .video
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openDocumentPicker(with mimeTypes: [String]) {
        let types = getDocumentTypes(from: mimeTypes)
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func getDocumentTypes(from mimeTypes: [String]) -> [String] {
        var documentTypes: [String] = []
        for mimeType in mimeTypes {
            switch mimeType {
            case "image/jpeg", "image/jpg":
                documentTypes.append(kUTTypeJPEG as String)
            case "image/png":
                documentTypes.append(kUTTypePNG as String)
            case "application/pdf":
                documentTypes.append(kUTTypePDF as String)
            case "image/bmp":
                documentTypes.append(kUTTypeBMP as String)
            default:
                break
            }
        }
        // remove duplicates
        let resultList = Array(Set(documentTypes))
        return resultList
    }
    
    func getSign(){
        docType = .sign
    }
    
    func userExit(){
        print(#function)
        FisdomSdk.shared().killSdk();
        FisdomSdk.shared().closeSDK()
        self.webView?.stopLoading()
        self.webView?.removeFromSuperview()
        let topViewC = self.navigationController?.popViewController(animated: true)
        if (topViewC == nil) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func makeBankPayment(arguments: [String: Any]) {
        UserDefaults.standard.set(arguments, forKey: AppConstant.shared.PREF_BANK_PAYMENT)
        FisdomSdk.shared().onPaymentRequired(paymentDetails: arguments)
    }
    
    func createImageDataDic(image: UIImage) -> [String : Any] {
        var blob: String = ""
        if docType == .video{
            blob = AppConstant.shared.convertToBase64new(dataObj: videoData!)
        }else{
            blob = AppConstant.shared.convertToBase64new(dataObj: AppConstant.shared.getCompressedData(forImage: image)!)
        }
        var fileType: String = ""
        var imageWithExt: String = ""
        switch docType {
        case .image:
            fileType = "image/jpg"
            imageWithExt = imageFileName
            break
        case .video:
            fileType = "video/mp4"
            imageWithExt = imageFileName
            break
        case .sign:
            fileType = "image/png"
            imageWithExt = imageFileName
            break
        }
        if checkLiveness {
            // Note: We must do below step, otherwise it will get updated for other image picker actions also
            checkLiveness = false
            let livenessResultDict = ["live": self.isLive,
                                      "liveness-score": self.livenessScore]
            let parameters: [String: Any] = ["doc_type": imageWithExt,
                              "file_type": fileType,
                              "blobBase64": blob,
                              "liveness_result": livenessResultDict]
            return parameters
        } else {
            return ["doc_type": imageWithExt, "file_type": fileType, "blobBase64": blob]
        }
    }
    
    func uploadImage(image: UIImage) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.createImageDataDic(image: image), options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let method1 = "callbackWeb.upload_blob(\(jsonString))"
                webView?.evaluateJavaScript(method1) { (value, error) in
                    //print(error)
                }
            } else {
                NSLog("failed to upload blob, found nil")
            }
            
        } catch {
            //print(error.localizedDescription)
        }
        
    }
    
    func thirdPartyRedirect(arguments: [String: Any]) {
        if let type: String = arguments["type"] as? String{
            if (type == "mandate") {
                setUseragent();
            }
        }
        thirdPartyReceived(arguments: arguments);
    }
    func changeTakeControllerStatus(){
        takeControl = 1;
        
    }
    
    func thirdPartyReceived(arguments: [String: Any]) {
        takeControl = 2;
        thirdPartyArguments = arguments;
        if let value = arguments["show_toolbar"] as? Bool{
            manageToolBar(isShowToolBar: value)
        }
    }
    
    func manageToolBar(isShowToolBar: Bool){
        print(#function)
        if isShowToolBar{
            NavigationBarView.backgroundColor = UIColor.gray
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let yPosition = statusBarHeight + 44 // NavigationBar
            webView?.frame = CGRect.init(x: view.frame.origin.x, y: view.frame.origin.y + yPosition , width: view.bounds.size.width, height: view.bounds.size.height - yPosition)
        }
        else{
            NavigationBarView.backgroundColor = UIColor.clear
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            webView?.frame = CGRect.init(x: view.frame.origin.x, y: statusBarHeight, width: view.bounds.size.width, height: view.bounds.size.height - statusBarHeight)
        }
    }
    
    func setUseragent(){
        if (!wasCustomSet) {
            wasCustomSet = true;
            UserDefaults.standard.register(defaults: ["UserAgent" : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36"])
        } else {
            wasCustomSet = false;
            UserDefaults.standard.unregister(defaultsFor: "UserAgent")
        }
    }
    
    func nativeIntent(intentDetails: [String: Any]) {
        if let message = intentDetails["message"] as? String{
            if let type = intentDetails["type"] as? String{
                switch type {
                case "browser":
                    if let url = URL.init(string: message) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    break
                case "native":
                    let textToShare: String = message
                    let objectsToShare = [textToShare] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    //New Excluded Activities Code
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    activityVC.popoverPresentationController?.sourceView = self.view
                    activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    }
                    // TODO: iOS 13 presentation handling
                    
                    self.present(activityVC, animated: true, completion: nil)
                    break;
                default:
                    break
                }
            }
        }
    }
}

extension FSSDKViewController: SignatureControllerDelegate{
    func controllerDismissed() {
        
    }
    func didSign(image: UIImage) {
        docType = .sign
        uploadImage(image: image)
    }
}

extension String{
    func encodeUrl() -> String
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    func decodeUrl() -> String
    {
        return self.removingPercentEncoding!
    }
    
    func decodeUrlSafely() -> String? {
        return self.removingPercentEncoding
    }
    
}

extension UserDefaults {
    /// Unregisters a value set in the UserDefaults.registrationDomain, if it exists
    func unregister(defaultsFor key: String) {
        var registeredDefaults = volatileDomain(forName: UserDefaults.registrationDomain)
        registeredDefaults[key] = nil
        setVolatileDomain(registeredDefaults, forName: UserDefaults.registrationDomain)
    }
}

// MARK:- DocumentPicker
extension FSSDKViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let filePath = urls.first else {
            return
        }
        uploadFile(at: filePath)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadFile(at filepath: URL) {
        let selectedFileType = filepath.pathExtension
        let localFileName = filepath.lastPathComponent
        guard let fileType = getMimeType(from: selectedFileType) else {
            return
        }
        guard let fileData = try? Data(contentsOf: filepath) else {
            return
        }
        let blob = fileData.base64EncodedString(options: .lineLength64Characters)
        let jsonObject = ["file_name": imageFileName,
                          "mime_type": fileType,
                          "file_name_local": localFileName,
                          "blobBase64": blob]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            debugPrint("Error while preparing JSON data")
            return
        }
        let uploadBlobScript = "callbackWeb.upload_blob(\(jsonString))"
        webView?.evaluateJavaScript(uploadBlobScript) { (value, error) in
//            print("error: \(error)")
        }
    }
    
    func getMimeType(from fileExtension: String) -> String? {
        switch fileExtension {
        case "jpeg":
            return "image/jpeg"
        case "jpg":
            return "image/jpg"
        case "png":
            return "image/png"
        case "pdf":
            return "application/pdf"
        case "bmp":
            return "image/bmp"
        default:
            return nil
        }
    }
}


// MARK:- Hyperverge SDK
extension FSSDKViewController {

    func launchHypervergeSDK() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showOkAlert(title: "Error", message: "Device has no camera")
            return
        }
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .denied,.restricted:
            DispatchQueue.main.async {
                self.alertPromptToAllowCameraAccessViaSettings()
            }
            return
        default:
            break
        }
        self.isLive = ""
        self.livenessScore = ""
        launchFaceCaptureScreen()
    }

    func launchFaceCaptureScreen() {
        let hvFaceConfig = HVFaceConfig()
        debugPrint("hvFaceConfig: \(hvFaceConfig)")
        let parameters = prepareLivenessParameters()
        hvFaceConfig.setLivenessMode(HyperSnapParams.LivenessMode.textureLiveness)
        hvFaceConfig.setLivenessAPIParameters(parameters)
        hvFaceConfig.setShouldShowInstructionsPage(true)
        HVFaceViewController.start(self, hvFaceConfig: hvFaceConfig) { (error, result, vcNew) in

            if let hvError = error {
                self.handleHVError(hvError)
            } else {
                guard let response = result else {
                    return
                }
                //This is the selfie of the customer stored in app memory
                guard let selfieImageUri: String = response.fullImageUri else {
                    return
                }
                guard let result = response.apiResult?["result"] as? [String: Any] else {
                    return
                }
                if let isLive = result["live"] as? String,
                   let score = result["liveness-score"] as? String {
                    self.didCapturImage(imagePath: selfieImageUri, live: isLive, livenessScore: score)
                }
            }
        }
    }

    func prepareLivenessParameters() -> [String: AnyObject] {
        let parameters = [ "allowEyesClosed" : "no",
                           "rejectFaceMask": "yes"]
        return parameters as [String: AnyObject]
    }

    func handleHVError(_ hvError: HVError) {
        let errorCode = hvError.getErrorCode()
        var errorMsg = ""
        switch errorCode {
        case 3:
            // Operation cancelled by user
            // Do nothing
            return
        case 4:
            // Camera Permission Denied
            verifyCameraAutherizationStatus()
            return
        case 12:
            // Network Error. Not connected to internet.
            errorMsg = Constants.STATUS_MSG_INTERNET_ISSUE
        case 22, 23, 423:
            // Face could not be detected in the image by the server" (ex: mask etc)
            showRetakeSelfieAlert()
            return
        default:
            errorMsg = Constants.STATUS_MSG_SWW_ISSUE
        }
        let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            debugPrint("(action): \((action))")
        }
        showAlertWithAction(title: "", message: errorMsg, action: okAction)
    }

    func didCapturImage(imagePath: String, live: String, livenessScore: String) {
        self.isLive = live
        self.livenessScore = livenessScore
        guard let image = UIImage(contentsOfFile: imagePath) else {
            return
        }
        self.checkLiveness = true
        uploadImage(image: image)
    }

    func verifyCameraAutherizationStatus() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .denied,.restricted:
            DispatchQueue.main.async {
                self.alertPromptToAllowCameraAccessViaSettings()
            }
        default:
            break
        }
    }

    func showRetakeSelfieAlert() {
        let errorMsg = "Selfie capture failed"
        let buttonTitle = "Retake"
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { (_) in
            self.launchHypervergeSDK()
        }
        showAlertWithAction(title: "", message: errorMsg, action: okAction)
    }
}


// MARK:- sendResultToWeb after 2fa
extension FSSDKViewController : WebCallbackTwoFADelegate{
    func sendResultToWeb(resultCode : Int , data: [String: Any]){
        // removing whatever on the top of webview
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: false, completion: nil)
            self.set2faCookies()
            var resultStatus = ""
            switch (resultCode){
            case AppConstant.RESULT_OK:
                resultStatus = AppConstant.WEB_RESULT_SUCCESS
                break
            case AppConstant.RESULT_CANCELED:
                resultStatus = AppConstant.WEB_RESULT_FAILURE
                break
            default:
                resultStatus = AppConstant.WEB_RESULT_CANCELLED
                break
            }
            
            let uploadDict: [String: Any] = ["request_code": self.requestedCode, "status": resultStatus, "data": data]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: uploadDict, options: [])
                if let jsonString: String = String(data: jsonData, encoding: .utf8) {
                    let method1 = "callbackWeb.on_native_result(\(jsonString))"
                    self.webView?.evaluateJavaScript(method1) { (value, error) in
                        //print(error)
                    }
                } else {
                    self.sendErrorWeb(action: "on_native_result", errorMessage: "error while preparing json data")
                }
                
            } catch {
                //print(error.localizedDescription)
            }
        }
    }
    
    func set2faCookies(){
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        for cookie in cookies {
//            print(cookie)
            self.webView?.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
    }
    
    func sendErrorWeb(action: String, errorMessage: String) {
        do {
            let errorDict: [String: Any] = ["err_action_name": action, "err_message": errorMessage]
            let jsonData = try JSONSerialization.data(withJSONObject: errorDict, options: [])
            if let jsonString: String = String(data: jsonData, encoding: .utf8) {
                let method = "callbackWeb.post_error(\(jsonString))"
                self.webView?.evaluateJavaScript(method) { (value, error) in
                    //print(error)
                }
            }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
}
    
//MARK: - GeolocationServiceDelegate
extension FSSDKViewController: GeolocationServiceDelegate {
    func permissionDenied() {
        self.locationDenied()
        sendLocation(permissionAllowed: false)
    }
    
    func didFetchCurrentLocation(_ location: GeoLocation) {
        sendLocation( location : location, permissionAllowed: true)
    }
    
    func fetchCurrentLocationFailed(error: Error) {
        debugPrint(error.localizedDescription)
        self.locationDenied()
        sendLocation(permissionAllowed: false)
    }
}
