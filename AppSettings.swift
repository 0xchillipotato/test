//
//  AppSettings.swift
//  FisdomSDK
//
//  Created by Chandra Sekhar Y on 28/03/22.
//  Copyright © 2022 Abhishek Mishra. All rights reserved.
//

import Foundation


let defaults = UserDefaults.standard

func saveValueInUserDefaults(_ value: Any?, forKey key: String) {
    defaults.set(value, forKey: key)
}


class AppSettings {
    static let WAV2_SDK_CONFIG = "com.finwizard.fisdom.equity.sdk.config"
    fileprivate static let PREF_2FA_PIN_STATUS = "com.finwizard.fisdom.2fa.pin.status"
    fileprivate static let PREF_2FA_PIN = "com.finwizard.fisdom.2fa.pin"
    fileprivate static let PARTNER_SPLASH_LOGO = "com.finwizard.fisdom.partner.splash.logo"
    
    
    static let bundle = Bundle(identifier: "com.FisdomSDK.FisdomSDK") //com.FisdomSDK.FisdomSDK
    static let versionName = "1.0.3"
    static let versionCode = FisdomSDKVersionNumber
    
    fileprivate static func setPreference(_ name:String, value:String) {
        saveValueInUserDefaults(value, forKey: name)
    }
    fileprivate static func getPreference(_ name: String, defaultValue: String?) -> String? {
        guard let value = UserDefaults.standard.value(forKey: name) as? String else {
            return defaultValue
        }
        return value
    }
    
    fileprivate static func setPreference(_ name: String, value: [String: Any]) {
        saveValueInUserDefaults(value, forKey: name)
    }
    
    fileprivate static func getPreferenceAsDictionary(_ name: String, defaultValue: [String: Any]?) -> [String: Any]? {
        guard let value = UserDefaults.standard.object(forKey: name) as? [String: Any] else {
            return defaultValue
        }
        return value
    }
    
    static func getWave2SDKVersion() -> String {
        let wave2Config = AppSettings.getWave2Config()
        return wave2Config["version_code"] as? String ?? ""
    }
    
    static func setWave2Config(value: [String: Any]) {
        setPreference(WAV2_SDK_CONFIG, value: value)
    }
    
    static func getWave2Config() -> [String: Any] {
        return getPreferenceAsDictionary(WAV2_SDK_CONFIG, defaultValue: [:]) ?? [:]
    }

    static func isMyWay() -> Bool {
        switch AppConstant.environment {
        case appEnvironment.MYWAY.rawValue , appEnvironment.FINITY.rawValue:
            return true
        default:
            return false
        }
    }

    static func set2faPinStatus(pin : String){
           setPreference(PREF_2FA_PIN_STATUS, value: pin)
    }
       
    static func get2faPinStatus() -> String{
      return getPreference(PREF_2FA_PIN_STATUS, defaultValue: "")!
    }
    
    static func set2faPinValue(pin : String){
           setPreference(PREF_2FA_PIN, value: pin)
    }
       
    static func get2faPinValue() -> String{
      return getPreference(PREF_2FA_PIN, defaultValue: "")!
    }
    
    static func setPartnerSplashLogo(logoUrl: String){
        setPreference(PARTNER_SPLASH_LOGO, value: logoUrl)
    }
    
    static func getPartnerSplashLogo() -> String{
        return getPreference(PARTNER_SPLASH_LOGO, defaultValue: "")!
    }
}
