//
//  SDKEndPoint.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation

enum SDKApi {
    case loginByToken(partnerCode: String, customerInfo: [String: Any])
    case getUserAccountSnapShot
    case pingFisdomServer
    case logout
    case getTokenObj(data: [String: Any])
    case lvbLogin(data: [String: Any])
    case tppAuth
    case getDowntime
    case getAnalystViewHtml(data: [String: Any])
    case getAnalystRecommendationData
    case equityPayment(data: [String: Any])
    case setMpin(data: [String: Any])
    case verifyMpin(data: [String: Any])
    case resetMpin(data: [String: Any])
    case modifyMpin(resetUrl:String ,data: [String: Any])
    case forgetMpin(data: [String: Any])
    case authGetter
    case verifyOtp(verifyOtpUrl:String ,data: [String: Any])
    case resendOtp (resetUrl:String ,data: [String: Any])
    case preloadPartnerConfig(partnerCode: String)
    case analystRecommendationGetData(moduleName: String, data: [String: Any])
    case analystRecommendationPostData(moduleName: String, queryData: [String: Any], postData: [String: Any])
}

extension SDKApi: EndPointType {
    
    var environmentBaseURL : String {
        switch self {
        case .modifyMpin(let resetUrl, _):
            return resetUrl
        case .verifyOtp(let verifyUrl, _):
            return verifyUrl
        case .resendOtp(let resetUrl, _):
            return resetUrl
        default:
            return AppConstant.shared.getBackEndUrl() //uatBaseurl
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var isCompletePath : Bool{
        switch self {
        case .modifyMpin:
            return true
        case .verifyOtp:
            return true
        case .resendOtp:
            return true
        default:
            return false
        }
    }
    
    var path: String {
        switch self {
        case .loginByToken(let partnerCode, _):
            return "/api/partner/\(partnerCode)/user/login/v2"
        case .getUserAccountSnapShot:
            return "/api/user/getaccountsnapshot"
        case .pingFisdomServer:
            return "/api/iam/ping"
        case .logout:
            return "/api/logout"
        case .getTokenObj:
            return "/http-proxy"
        case .lvbLogin:
            return "/api/user/login"
        case .tppAuth:
            return "/api/equity/gettoken"
        case .getDowntime:
            return "/api/equity/api/eqm/downtime/all"
        case .getAnalystViewHtml(_):
            return "/page/equity/analystview"
        case .getAnalystRecommendationData:
            return "/api/equity/api/eqm/refinitive/recommendations"
        case .equityPayment:
            return "/api/equity/api/eqm/eqpayments/start/payment"
        case .setMpin:
            return "/api/iam/mpin/v2/set"
        case .verifyMpin:
            return "/api/iam/mpin/v2/verify"
        case .resetMpin:
            return "/api/iam/mpin/v2/modify"
        case .modifyMpin(_ , _):
            return ""
        case .forgetMpin:
            return "/api/iam/mpin/v2/forgot"
        case .authGetter:
            return "/api/iam/mpin/v2/get/obscured_auth"
        case .verifyOtp(_ , _):
            return ""
        case .resendOtp(_ , _):
            return ""
        case .preloadPartnerConfig(let partnerCode):
            return "api/partner/\(partnerCode)/logo"
        case .analystRecommendationGetData(let moduleName, _):
            return "/api/equity/additionaldata/\(moduleName)"
        case .analystRecommendationPostData(let moduleName, _, _):
            return "/api/equity/additionaldata/\(moduleName)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .loginByToken:
            return .post
        case .getUserAccountSnapShot:
            return .get
        case .pingFisdomServer:
            return .get
        case .logout:
            return .get
        case .getTokenObj:
            return .post
        case .lvbLogin:
             return .post
        case .tppAuth:
            return .get
        case .getDowntime:
            return .get
        case .getAnalystViewHtml:
            return .get
        case .getAnalystRecommendationData:
            return .get
        case .equityPayment:
            return .post
        case .setMpin:
            return .post
        case .verifyMpin:
            return .post
        case .resetMpin:
            return .post
        case .modifyMpin:
            return .post
        case .forgetMpin:
            return .post
        case .authGetter:
            return .get
        case .verifyOtp:
            return .post
        case .resendOtp:
            return .post
        case .preloadPartnerConfig:
            return .get
        case .analystRecommendationGetData:
            return .get
        case .analystRecommendationPostData:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .loginByToken( _, let customerInfo):
                return .requestParameters(bodyParameters: customerInfo,
                                          bodyEncoding: .jsonEncoding,
                                          urlParameters: nil)
        case .getUserAccountSnapShot:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .pingFisdomServer:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .logout:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .getTokenObj(let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .lvbLogin(let data):
            return .multipartRequest(bodyParameters: data)
        case .tppAuth:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .getDowntime:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .getAnalystViewHtml(let data):
            return .requestHtml(bodyParameters: nil,
                                bodyEncoding: .urlEncoding,
                                urlParameters: data)
        case .getAnalystRecommendationData:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .equityPayment(let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .setMpin(let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .verifyMpin(let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .resetMpin(let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .modifyMpin(_ , let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .forgetMpin(let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .authGetter:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .verifyOtp(_ , let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .resendOtp(_ , let data):
            return .requestParameters(bodyParameters: data,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .preloadPartnerConfig:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .analystRecommendationGetData(_, let data):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: data)
        case .analystRecommendationPostData(_, let queryData, let postData):
            return .requestParameters(bodyParameters: postData,
                                      bodyEncoding: .urlAndJsonEncoding,
                                      urlParameters: queryData)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getTokenObj:
            return ["Ralg": "2"]
        default:
            return nil
        }
    }
}
