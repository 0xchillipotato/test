//
//  File.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation

struct encryptOBJ{
    var enc: String = ""
}

extension encryptOBJ: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case enc = "_encr_payload"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let enc = try container.decodeIfPresent(String.self, forKey: .enc){
            self.enc = enc
        }
    }
}

struct LoginResult {
    var message: String = ""
    var email: String = ""
    var pingInterval: Double = 0
    var userStatusCode: Int = 0
    var error: String = ""
    var firstLogin: Bool = false
    var subbrokerId : Double = 0
    var isInsuranceEnabled: Bool = false
    var session: Session?
    var subbroker: String = ""
    var user: FisdomUser?
    var partner: Partner?
    var partner_user_data : Partner_Data?
}

extension LoginResult: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case userStatusCode = "user_status_code"
        case message
        case error
        case subbrokerId = "subbroker_id"
        case isInsuranceEnabled = "insurance_enabled"
        case session
        case subbroker
        case user
        case email
        case pingInterval = "ping_interval"
        case partner
        case partner_user_data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let userStatusCode = try container.decodeIfPresent(Int.self, forKey: .userStatusCode){
            self.userStatusCode = userStatusCode
        }
        if let message = try container.decodeIfPresent(String.self, forKey: .message){
            self.message = message
        }
        if let error = try container.decodeIfPresent(String.self, forKey: .error){
            self.error = error
        }
        if let subbrokerId = try container.decodeIfPresent(Double.self, forKey: .subbrokerId){
            self.subbrokerId = subbrokerId
        }
        if let isInsuranceEnabled = try container.decodeIfPresent(Bool.self, forKey: .isInsuranceEnabled){
            self.isInsuranceEnabled = isInsuranceEnabled
        }
        if let session = try container.decodeIfPresent(Session.self, forKey: .session){
            self.session = session
        }
        if let subbroker = try container.decodeIfPresent(String.self, forKey: .subbroker){
            self.subbroker = subbroker
        }
        if let user = try container.decodeIfPresent(FisdomUser.self, forKey: .user){
            self.user = user
        }
        if let email = try container.decodeIfPresent(String.self, forKey: .email){
            self.email = email
        }
        if let pingInterval = try container.decodeIfPresent(Double.self, forKey: .pingInterval){
            self.pingInterval = pingInterval
        }
        if let partner = try container.decodeIfPresent(Partner.self, forKey: .partner){
            self.partner = partner
        }
        if let partner_user_data = try container.decodeIfPresent(Partner_Data.self, forKey: .partner_user_data){
            self.partner_user_data = partner_user_data
        }
    }
}

struct FisdomUser {
    var forcedReset: Bool = false
    var dob: String = ""
    var userId: String = ""
    var promotionFlag: Bool = false
    var hasMpin: Bool = false
    var npsInvestment: Bool = false
    var insuranceActive: Bool = false
    var isKycCompliant: Bool = false
    var name: String = ""
    var isVarified: Bool = false
    var kycRegistration: Bool = false
    var promptSign: String = "ignore"
    var dtFirstInvestment: String = ""
    var kycRegistrationV2: String = ""
    var acceptedReferralCode: String = ""
    var activeInvestment: Bool = false
    var screen: String = ""
    var isEnabled: Bool = false
    var email: String = ""
    var mobile: String = ""
    var isRegister: Bool = false
    var isFirstLogin: Bool = false
    var referralCode: String = ""
    var pinStatus: String = ""
    var onboardChannels: [OnboardChannels]?
}
    
extension FisdomUser: Decodable{
    
    private enum OTPResponseCodingKeys: String, CodingKey {
        case forcedReset = "forced_reset"
        case dob
        case userId = "user_id"
        case promotionFlag = "promotion_flag"
        case hasMpin = "has_mpin"
        case npsInvestment = "nps_investment"
        case insuranceActive = "insurance_active"
        case isKycCompliant = "is_kyc_compliant"
        case name
        case isVarified = "verified"
        case kycRegistration = "kyc_registration"
        case promptSign = "prompt_sign"
        case dtFirstInvestment = "dt_first_investment"
        case kycRegistrationV2 = "kyc_registration_v2"
        case acceptedReferralCode = "accepted_referral_code"
        case activeInvestment = "active_investment"
        case screen = "screen"
        case isEnabled = "is_enabled"
        case email
        case mobile
        case userTheme = "user_theme"
        case isFirstLogin = "firstLogin"
        case referralCode = "referral_code"
        case pinStatus = "pin_status"
        case onboardChannels = "onboard_channels"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let forcedReset = try container.decodeIfPresent(Bool.self, forKey: .forcedReset){
            self.forcedReset = forcedReset
        }
        if let dob = try container.decodeIfPresent(String.self, forKey: .dob){
            self.dob = dob
        }
        if let userId = try container.decodeIfPresent(String.self, forKey: .userId){
            self.userId = userId
        }
        if let promotionFlag = try container.decodeIfPresent(Bool.self, forKey: .promotionFlag){
            self.promotionFlag = promotionFlag
        }
        if let hasMpin = try container.decodeIfPresent(Bool.self, forKey: .hasMpin){
            self.hasMpin = hasMpin
        }
        if let npsInvestment = try container.decodeIfPresent(Bool.self, forKey: .npsInvestment){
            self.npsInvestment = npsInvestment
        }
        if let insuranceActive = try container.decodeIfPresent(Bool.self, forKey: .insuranceActive){
            self.insuranceActive = insuranceActive
        }
        if let isKycCompliant = try container.decodeIfPresent(Bool.self, forKey: .isKycCompliant){
            self.isKycCompliant = isKycCompliant
        }
        if let name = try container.decodeIfPresent(String.self, forKey: .name){
            self.name = name
        }
        if let isVarified = try container.decodeIfPresent(Bool.self, forKey: .isVarified){
            self.isVarified = isVarified
        }
        if let kycRegistration = try container.decodeIfPresent(Bool.self, forKey: .kycRegistration){
            self.kycRegistration = kycRegistration
        }
        if let promptSign = try container.decodeIfPresent(String.self, forKey: .promptSign){
            self.promptSign = promptSign
        }
        if let dtFirstInvestment = try container.decodeIfPresent(String.self, forKey: .dtFirstInvestment){
            self.dtFirstInvestment = dtFirstInvestment
        }
        if let email = try container.decodeIfPresent(String.self, forKey: .email){
            self.email = email
        }
        if let mobile = try container.decodeIfPresent(String.self, forKey: .mobile){
            self.mobile = mobile
        }
        if let kycRegistrationV2 = try container.decodeIfPresent(String.self, forKey: .kycRegistrationV2){
            self.kycRegistrationV2 = kycRegistrationV2
        }
        if let acceptedReferralCode = try container.decodeIfPresent(String.self, forKey: .acceptedReferralCode){
            self.acceptedReferralCode = acceptedReferralCode
        }
        if let activeInvestment = try container.decodeIfPresent(Bool.self, forKey: .activeInvestment){
            self.activeInvestment = activeInvestment
        }
        if let screen = try container.decodeIfPresent(String.self, forKey: .screen){
            self.screen = screen
        }
        if let isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled){
            self.isEnabled = isEnabled
        }
        if let isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled){
            self.isEnabled = isEnabled
        }
        if let isFirstLogin = try container.decodeIfPresent(Bool.self, forKey: .isFirstLogin){
            self.isFirstLogin = isFirstLogin
        }
        if let referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode){
            self.referralCode = referralCode
        }
        if let pinStatus = try container.decodeIfPresent(String.self, forKey: .pinStatus){
            self.pinStatus = pinStatus
        }
        if let onboardChannels = try container.decodeIfPresent([OnboardChannels].self, forKey: .onboardChannels){
            self.onboardChannels = onboardChannels
        }
    }
}

struct Session {
    var isVarified: Bool = false
}

extension Session: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case isVarified = "verified"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let isVarified = try container.decodeIfPresent(Bool.self, forKey: .isVarified){
            self.isVarified = isVarified
        }
    }
}

struct Partner {
    var apiKey: String = ""
    var companyName: String = ""
    var hostToSdkPingInterval: Double = 60
    var inactivityTimeoutDuration: Double = 30
    var logoutOnExit: Bool = false
    var partnerCode: String = ""
    var sdkToHostPingInterval: Double = 60
    var sessionTimeoutDuration: Double = 30
}

extension Partner: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case companyName = "company_name"
        case hostToSdkPingInterval = "host_to_sdk_ping_interval"
        case inactivityTimeoutDuration = "inactivity_timeout_duration"
        case logoutOnExit = "logout_on_exit"
        case partnerCode = "partner_code"
        case sdkToHostPingInterval = "sdk_to_host_ping_interval"
        case sessionTimeoutDuration = "session_timeout_duration"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let apiKey = try container.decodeIfPresent(String.self, forKey: .apiKey){
            self.apiKey = apiKey
        }
        if let companyName = try container.decodeIfPresent(String.self, forKey: .companyName){
            self.companyName = companyName
        }
        if let hostToSdkPingInterval = try container.decodeIfPresent(Double.self, forKey: .hostToSdkPingInterval){
            self.hostToSdkPingInterval = hostToSdkPingInterval
        }
        if let inactivityTimeoutDuration = try container.decodeIfPresent(Double.self, forKey: .inactivityTimeoutDuration){
            self.inactivityTimeoutDuration = inactivityTimeoutDuration
        }
        if let logoutOnExit = try container.decodeIfPresent(Bool.self, forKey: .logoutOnExit){
            self.logoutOnExit = logoutOnExit
        }
        if let partnerCode = try container.decodeIfPresent(String.self, forKey: .partnerCode){
            self.partnerCode = partnerCode
        }
        if let sdkToHostPingInterval = try container.decodeIfPresent(Double.self, forKey: .sdkToHostPingInterval){
            self.sdkToHostPingInterval = sdkToHostPingInterval
        }
        if let sessionTimeoutDuration = try container.decodeIfPresent(Double.self, forKey: .sessionTimeoutDuration){
            self.sessionTimeoutDuration = sessionTimeoutDuration
        }
        
    }
}

@objc public class Partner_Data : NSObject,Decodable {
      @objc open var gold_invested: Bool = false
      @objc open var nps_invested: Bool = false
      @objc open var first_login: Bool = false
      @objc open var fisdom_user_id: Double = 0
      @objc open var mf_invested: Bool = false
      @objc open var kyc_status: String = ""

    private enum OTPResponseCodingKeys: String, CodingKey {
        case gold_invested = "gold_invested"
        case nps_invested = "nps_invested"
        case first_login = "first_login"
        case fisdom_user_id = "fisdom_user_id"
        case mf_invested = "mf_invested"
        case kyc_status = "kyc_status"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)

        if let gold_invested = try container.decodeIfPresent(Bool.self, forKey: .gold_invested){
            self.gold_invested = gold_invested
        }
        if let nps_invested = try container.decodeIfPresent(Bool.self, forKey: .nps_invested){
            self.nps_invested = nps_invested
        }
        if let first_login = try container.decodeIfPresent(Bool.self, forKey: .first_login){
            self.first_login = first_login
        }
        if let fisdom_user_id = try container.decodeIfPresent(Double.self, forKey: .fisdom_user_id){
            self.fisdom_user_id = fisdom_user_id
        }
        if let mf_invested = try container.decodeIfPresent(Bool.self, forKey: .mf_invested){
            self.mf_invested = mf_invested
        }
        if let kyc_status = try container.decodeIfPresent(String.self, forKey: .kyc_status){
            self.kyc_status = kyc_status
        }
    }
}



struct OnboardChannels {
    var channelId: String = ""
    var channelType: String = ""
    var dtCreated: String = ""
}

extension OnboardChannels: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case channelId = "channel_id"
        case channelType = "channel_type"
        case dtCreated = "dt_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let channelId = try container.decodeIfPresent(String.self, forKey: .channelId){
            self.channelId = channelId
        }
        if let channelType = try container.decodeIfPresent(String.self, forKey: .channelType){
            self.channelType = channelType
        }
        if let dtCreated = try container.decodeIfPresent(String.self, forKey: .dtCreated){
            self.dtCreated = dtCreated
        }
    }
}

struct PingResult {
    var message: String = ""
}

extension PingResult: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        if let message = try container.decodeIfPresent(String.self, forKey: .message){
            self.message = message
        }
    }
}

@objc public class UserAccountDetails: NSObject, Decodable {
    @objc open var activeInvestment: Bool = false
    @objc open var current: Double = 0
    @objc open var earning: Double = 0
    @objc open var invested: Double = 0
    @objc open var kycRegistrationV2: String = ""
    @objc open var oneDayEarnings: Double = 0
    @objc open var pendingInvested: Double = 0
    @objc open var pendingRedeemed: Double = 0
    @objc open var pendingSwitch: Double = 0
    @objc open var redeemed: Double = 0
    @objc open var error: String = ""
    
    private enum OTPResponseCodingKeys: String, CodingKey {
        case activeInvestment = "active_investment"
        case current
        case earning
        case invested
        case kycRegistrationV2 = "kyc_registration_v2"
        case oneDayEarnings = "one_day_earnings"
        case pendingInvested = "pending_invested"
        case pendingRedeemed = "pending_redeemed"
        case pendingSwitch = "pending_switch"
        case redeemed
        case error
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let activeInvestment = try container.decodeIfPresent(Bool.self, forKey: .activeInvestment){
            self.activeInvestment = activeInvestment
        }
        if let current = try container.decodeIfPresent(Double.self, forKey: .current){
            self.current = current
        }
        if let earning = try container.decodeIfPresent(Double.self, forKey: .earning){
            self.earning = earning
        }
        if let invested = try container.decodeIfPresent(Double.self, forKey: .invested){
            self.invested = invested
        }
        if let kycRegistrationV2 = try container.decodeIfPresent(String.self, forKey: .kycRegistrationV2){
            self.kycRegistrationV2 = kycRegistrationV2
        }
        if let oneDayEarnings = try container.decodeIfPresent(Double.self, forKey: .oneDayEarnings){
            self.oneDayEarnings = oneDayEarnings
        }
        if let pendingInvested = try container.decodeIfPresent(Double.self, forKey: .pendingInvested){
            self.pendingInvested = pendingInvested
        }
        if let pendingRedeemed = try container.decodeIfPresent(Double.self, forKey: .pendingRedeemed){
            self.pendingRedeemed = pendingRedeemed
        }
        if let pendingSwitch = try container.decodeIfPresent(Double.self, forKey: .pendingSwitch){
            self.pendingSwitch = pendingSwitch
        }
        if let redeemed = try container.decodeIfPresent(Double.self, forKey: .redeemed){
            self.redeemed = redeemed
        }
        if let error = try container.decodeIfPresent(String.self, forKey: .error){
            self.error = error
        }
    }
}

//extension UserAccountDetails: Decodable{
//    private enum OTPResponseCodingKeys: String, CodingKey {
//        case activeInvestment = "active_investment"
//        case current
//        case earning
//        case invested
//        case kycRegistrationV2 = "kyc_registration_v2"
//        case oneDayEarnings = "one_day_earnings"
//        case pendingInvested = "pending_invested"
//        case pendingRedeemed = "pending_redeemed"
//        case pendingSwitch = "pending_switch"
//        case redeemed
//        case error
//    }
//    
//    required convenience public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
//        
//        if let activeInvestment = try container.decodeIfPresent(Bool.self, forKey: .activeInvestment){
//            self.activeInvestment = activeInvestment
//        }
//        if let current = try container.decodeIfPresent(Double.self, forKey: .current){
//            self.current = current
//        }
//        if let earning = try container.decodeIfPresent(Double.self, forKey: .earning){
//            self.earning = earning
//        }
//        if let invested = try container.decodeIfPresent(Double.self, forKey: .invested){
//            self.invested = invested
//        }
//        if let kycRegistrationV2 = try container.decodeIfPresent(String.self, forKey: .kycRegistrationV2){
//            self.kycRegistrationV2 = kycRegistrationV2
//        }
//        if let oneDayEarnings = try container.decodeIfPresent(Double.self, forKey: .oneDayEarnings){
//            self.oneDayEarnings = oneDayEarnings
//        }
//        if let pendingInvested = try container.decodeIfPresent(Double.self, forKey: .pendingInvested){
//            self.pendingInvested = pendingInvested
//        }
//        if let pendingRedeemed = try container.decodeIfPresent(Double.self, forKey: .pendingRedeemed){
//            self.pendingRedeemed = pendingRedeemed
//        }
//        if let pendingSwitch = try container.decodeIfPresent(Double.self, forKey: .pendingSwitch){
//            self.pendingSwitch = pendingSwitch
//        }
//        if let redeemed = try container.decodeIfPresent(Double.self, forKey: .redeemed){
//            self.redeemed = redeemed
//        }
//        if let error = try container.decodeIfPresent(String.self, forKey: .error){
//            self.error = error
//        }
//    }
//}

struct DialogObj {
    var actionArr = [Action]()
    var message: String = ""
    
    init(obj: [String: Any]) {
        if let actionArr = obj["action"] as? [Any]{
            for obj in actionArr{
                if let value = obj as? [String: Any]{
                    self.actionArr.append(Action(obj: value))
                }
            }
        }
        if let msg = obj["message"] as? String{
            self.message = msg
        }
    }
}

struct Action{
    var actionName: String = ""
    var actionText: String = ""
    var actionType: String = ""
    var redirectUrl: String = ""
    
    init(obj: [String: Any]) {
        if let name = obj["action_name"] as? String{
            self.actionName = name
        }
        if let text = obj["action_text"] as? String{
            self.actionText = text
        }
        if let type = obj["action_type"] as? String{
            self.actionType = type
        }
        if let url = obj["redirect_url"] as? String{
            self.redirectUrl = url
        }
    }
}

struct PaymentDetail {
    var fisdomTransactionId: String = ""
    var transactionId: String = ""
    var accountNumber: String = ""
    var paymentComplete: Bool = false
    var amount: Double = 0
}

struct PreloadConfigResult {
    var logoUrl: String = ""
    var message: String = ""
    var error: String = ""
}

extension PreloadConfigResult: Decodable{
    private enum OTPResponseCodingKeys: String, CodingKey {
        case logoUrl = "logo_url"
        case message
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OTPResponseCodingKeys.self)
        
        if let message = try container.decodeIfPresent(String.self, forKey: .message){
            self.message = message
        }
        if let error = try container.decodeIfPresent(String.self, forKey: .error){
            self.error = error
        }
        if let email = try container.decodeIfPresent(String.self, forKey: .logoUrl){
            self.logoUrl = email
        }
    }
}
