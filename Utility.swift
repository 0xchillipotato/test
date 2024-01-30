//
//  Utility.swift
//  FisdomSDK
//
//  Created by ios_dev on 20/11/20.
//  Copyright © 2020 Abhishek Mishra. All rights reserved.
//

import Foundation
import WebKit
import HyperSnapSDK
import CoreTelephony

func print(_ object: Any) {
    //    #if DEBUG
    Swift.print(object)
    //    #endif
}

func print(_ object: Any...) {
    //    #if DEBUG
    for item in object {
        Swift.print(item)
    }
    //    #endif
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}


class CustomWKScriptMessageHandler : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("CustomWKScriptMessageHandler:  WKUserContentController, didReceive message")
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

func getKeyWindow() -> UIWindow? {
    
    if let window = UIApplication.shared.delegate?.window,
       let keyWindow = window {
        return keyWindow
    }
    if let appKeyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
        return appKeyWindow
    }
    return UIApplication.shared.keyWindow
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var topViewController = self.rootViewController
        while true {
            if let presentedController = topViewController?.presentedViewController {
                topViewController = presentedController
            } else if let navigationController = topViewController as? UINavigationController {
                topViewController = navigationController.visibleViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                break
            }
        }
        return topViewController
    }
}

extension UIViewController {
    
    func showBackButton(icon: String = "back_primary", tintColor: UIColor? = UIColor.white) {
        self.navigationItem.hidesBackButton = false
        let backButton = UIButton(type: UIButton.ButtonType.system)
        let image = UIImage(named: icon,
                            in: Bundle(for: type(of:self)),
                            compatibleWith: nil)
        backButton.setImage(image, for: .normal)
        backButton.tintColor = tintColor
        backButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -30, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(onBackPressed(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    @objc func onBackPressed(_ sender : UIButton) {
        _ = self.navigationController?.popViewController(animated : true)
    }
    
    func moveToPinSetupView(flow : pinFlow = .setPin , delegate : WebCallbackTwoFADelegate){
        let storyboardBundle = Bundle(for: SetPinViewController.self)
        let controller = SetPinViewController(nibName: "SetPinViewController", bundle: storyboardBundle)
        controller.flow = flow
        controller.WebCallbackdelegate = delegate
        let navigationController = UINavigationController(rootViewController: controller)
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = .fullScreen
        }
        navigationController.setNavigationBarHidden(false, animated: false)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func moveToResetPinView(delegate : WebCallbackTwoFADelegate){
        let storyboardBundle = Bundle(for: CurrentPinViewController.self)
        let controller = CurrentPinViewController(nibName: "CurrentPinViewController", bundle: storyboardBundle)
        controller.WebCallbackdelegate = delegate
        let navigationController = UINavigationController(rootViewController: controller)
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = .fullScreen
        }
        navigationController.setNavigationBarHidden(false, animated: false)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showNavigationBar(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension VPMOTPView {
    func configure(withDelegate delegate: VPMOTPViewDelegate) {
        self.otpFieldsCount = 4
        self.otpFieldDefaultBorderColor = Constants.primaryColor
        self.otpFieldDefaultBackgroundColor = Constants.whitegreyColor
        self.otpFieldEnteredBorderColor = Constants.primaryColor
        self.otpFieldErrorBorderColor = Constants.otpErrorBorderColor
        self.otpFieldBorderWidth = 1
        self.otpFieldSeparatorSpace = 20.0
        self.otpFieldSize = 30.0
        if let font = UIFont(name: "Rubik-Regular", size: 13) {
            self.otpFieldFont = font
        }
        self.delegate = delegate
        self.shouldAllowIntermediateEditing = false
        self.otpFieldDisplayType = .underlinedBottom
        self.initializeUI()
    }
}


// Don't delete following code, might be useful in future

//extension UIWindow {
//    func topViewController() -> UIViewController? {
//        var topViewController = self.rootViewController
//        while true {
//            if let presentedController = topViewController?.presentedViewController,
//                !presentedController.isBeingDismissed {
//                topViewController = presentedController
//            } else if let navigationController = topViewController as? UINavigationController {
//                topViewController = navigationController.visibleViewController
//            } else if let tabBarController = topViewController as? UITabBarController {
//                topViewController = tabBarController.selectedViewController
//            } else {
//                break
//            }
//        }
//        return topViewController
//    }
//}

func open2FAAuth(viewControllerToPresent viewController: UIViewController, delegate : WebCallbackTwoFADelegate){
    DispatchQueue.main.async {
        let storyboardBundle = Bundle(for: AuthenticationVerificationViewController.self)
        let storyboard = UIStoryboard(name: "Biometic", bundle: storyboardBundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "AuthenticationVerificationViewController") as? AuthenticationVerificationViewController else { return  }
        controller.WebCallbackdelegate = delegate
        controller.forgotFlow = .fromWebview
        let navigationController = UINavigationController(rootViewController: controller)
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = .fullScreen
        }
        navigationController.setNavigationBarHidden(false, animated: false)
        viewController.present(navigationController, animated: true, completion: nil)
    }
}

func moveToGenericWebView(url : String, isEquityPayment: Bool = false, _ paymentResultcallback: ViewCallback? = nil){
    
    let storyboardBundle = Bundle(for: FSSDKViewController.self)
    let storyboard =  UIStoryboard(name: "SDKMain", bundle: storyboardBundle)
    guard let genericWebController = storyboard.instantiateViewController(withIdentifier: "sdkViewId") as? FSSDKViewController else {
        return
    }
    genericWebController.isEquityPayment = isEquityPayment
    genericWebController.isPayment = false
    genericWebController.urlToOpenWebview = url
    
    if #available(iOS 13.0, *) {
        genericWebController.modalPresentationStyle = .fullScreen
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
    print("topViewController: \(topViewController)")
    
    if let paymentCallback = paymentResultcallback {
        genericWebController.setcallback(paymentCallback)
    }
    topViewController.navigationController?.pushViewController(genericWebController, animated: true)
}

func showOkAlert(title: String, message: String) {
    
    DispatchQueue.main.async {
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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        topViewController.present(alertController, animated: true, completion: nil)
    }
}


func showAlertWithAction(title: String, message: String, action : UIAlertAction) {
    DispatchQueue.main.async {
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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        topViewController.present(alertController, animated: true, completion: nil)
    }
}

func showAlertWithMultipleActions(alertText : String ,goAction : UIAlertAction , title : String) {
    DispatchQueue.main.async {
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
        
        let alertController = UIAlertController(title: title, message: alertText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        alertController.addAction(goAction)
        alertController.addAction(cancelAction)
        topViewController.present(alertController, animated: true, completion: nil)
    }
    
}

func isValidPin(pin : String) -> Bool {
    if (pin.count != 4) {
        return false
    } else if (hasConsecutiveNumbers(pin)) {
        return false
    } else if (hasAllSameCharacters(pin)) {
        return false
    }
    return true
}

func hasConsecutiveNumbers(_ pin : String) -> Bool {
    let asc = "0123456789"
    let desc = "9876543210"
    guard (asc.contains(pin) || desc.contains(pin)) else {
        return false
    }
    return true
}

func hasAllSameCharacters(_ pin : String) -> Bool {
    var someSet = Set<Character>()
    for c in pin{
        someSet.insert(c)
    }
    return someSet.count == 1
}

func is2faPinSetup() -> Bool {
    let pinStatus = AppSettings.get2faPinStatus()
    guard pinStatus == TwoFADataHandler.sharedInstance().PIN_SETUP_COMPLETED else  {
        return false
    }
    return true
}


func setupHypervergeSDK() {
    // Hyperverge SDK setup
    HyperSnapSDKConfig.initialize(appId: Constants.hypervergeSDKAppId, appKey: Constants.hypervergeSDKAppKey, region: HyperSnapParams.Region.India)
}

func carrierName() -> String{
    let info = CTTelephonyNetworkInfo()
    let carrier = info.subscriberCellularProvider
    if carrier != nil && carrier?.mobileNetworkCode == nil{
        return ""
    }
    return carrier?.carrierName ?? ""
}

func getUUID() -> String {
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
        return uuid
    }
    return ""
}

func fixiOS15NavBarIssues(navigationBar: UINavigationBar) {
    print(#function)
    if #available(iOS 15, *) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = Constants.primaryColor //customised nav bar background color
        navigationBar.barTintColor = Constants.primaryColor
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}

extension URL {
    public var queryParams: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
