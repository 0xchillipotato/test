//
//  SDKNetworkManager.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation
import SwiftyJSON

class SDKNetworkManager {
    
    let SOMETHING_WENT_WRON = "Something went wrong"
    
    let router = Router<SDKApi>()
    
    func loginByToken(partnerCode: String, customerInfo: [String: Any], completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<LoginResult>?, _ msg: String) ->()){
        router.request(.loginByToken(partnerCode: partnerCode, customerInfo: customerInfo)) { data, msg, isSuccess  in
            
            NSLog("loginByToken response:")
            print("msg:\(msg ?? "nil") isSuccess:\(isSuccess)")
            
            if isSuccess{
                guard let responseData = data else {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<LoginResult>.self, from: responseData)
                    print("apiResponse = \(apiResponse)")
                    print("apiResponse.statuscode = \(apiResponse.statuscode)")
                    
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        AppConstant.shared.setTokenVerified(verify: true)
                        var dictOfPfwResponse : [String:Any] = [:]
                        var dictOfResult : [String:Any] = [:]
                        var partnerUserData : [String:Any] = [:]
                        let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                        
                        
                        if let pfwresponse = json?["pfwresponse"]  as? [String: Any]{
                            dictOfPfwResponse = pfwresponse
                        }
                        if let result = dictOfPfwResponse["result"]  as? [String: Any]{
                            dictOfResult = result
                        }
                        if let partnerData = dictOfResult["partner_user_data"]  as? [String: Any]{
                            partnerUserData = partnerData
                        }
                        // need to update it
                        let pinStatus = apiResponse.response?.result?.user?.pinStatus ?? ""
                        AppSettings.set2faPinStatus(pin: pinStatus)
                        AppConstant.shared.user_result = dictOfResult
                        let partnerJsonData = try JSONSerialization.data(withJSONObject: partnerUserData, options: [])
                        if let partnerjsonString = String(data: partnerJsonData, encoding: .utf8) {
                            AppConstant.shared.partnerData = partnerjsonString
                        }
                        
                        DispatchQueue.main.async {
                            completion(.showDataView, apiResponse, apiResponse.message)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            completion(.errorView, apiResponse, apiResponse.message)
                        }
                    }
                }catch {
                    //                    print(error)
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func pingFisdomServer(completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<PingResult>?, _ msg: String) ->()){
        router.request(.pingFisdomServer) { data, msg, isSuccess  in
            
            if isSuccess{
                guard let responseData = data else {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<PingResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue{
                        DispatchQueue.main.async {
                            completion(.showDataView, apiResponse, apiResponse.message)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            completion(.errorView, apiResponse, apiResponse.message)
                        }
                    }
                }catch {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func logout(completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<LoginResult>?, _ msg: String) ->()){
        router.request(.logout) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<LoginResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue{
                        DispatchQueue.main.async {
                            completion(.showDataView, apiResponse, apiResponse.message)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            completion(.errorView, apiResponse, apiResponse.message)
                        }
                    }
                }catch {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func getAnalystViewHtml(params: [String: Any], completion: @escaping (String?) -> Void) {
        router.requestHTTPGetHtml(.getAnalystViewHtml(data: params)) { responseHtml in
            completion(responseHtml)
        }
    }
    
    func set2FAPin( data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<SetMpinResult>?, _ msg: String) ->()) {
        router.request(.setMpin(data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<SetMpinResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func verify2FAPin( data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<VerifyMpinResult>?, _ msg: String) ->()) {
        router.request(.verifyMpin(data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<VerifyMpinResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func reset2FAPin( data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<ModifyMpinResult>?, _ msg: String) ->()) {
        router.request(.resetMpin(data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<ModifyMpinResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    // need to check for
    func modify2FAPin( resetUrl:String , data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<ModifyMpinResult>?, _ msg: String) ->()) {
        router.request(.modifyMpin(resetUrl: resetUrl, data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<ModifyMpinResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        //
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func forget2FAPin( data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<ForgetMpinResult>?, _ msg: String) ->()) {
        router.request(.forgetMpin(data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<ForgetMpinResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func verifyOtp( verifyUrl:String , data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<VerifyOtpResult>?, _ msg: String) ->()) {
        router.request(.verifyOtp(verifyOtpUrl: verifyUrl, data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<VerifyOtpResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func resendOtp( resendUrl:String, data: [String : Any] , completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<ResendOtpResult>?, _ msg: String) ->()) {
        router.request(.resendOtp(resetUrl: resendUrl, data: data)) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<ResendOtpResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func getAuth(completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<AuthGetterResult>?, _ msg: String) ->()) {
        router.request(.authGetter) { data, msg, isSuccess  in
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<AuthGetterResult>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func preloadPartnerConfig(partnerCode: String, completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<PreloadConfigResult>?, _ msg: String) ->()){
        print(#function)
        router.request(.preloadPartnerConfig(partnerCode: partnerCode)) { data, msg, isSuccess  in
            NSLog("preloadPartnerConfig API")
            print("msg:\(msg ?? "nil") isSuccess: \(isSuccess)")
            
            if isSuccess{
                guard let responseData = data else {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<PreloadConfigResult>.self, from: responseData)
                    print("statuscode = \(apiResponse.statuscode)")
                    
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        DispatchQueue.main.async {
                            completion(.showDataView, apiResponse, apiResponse.message)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            completion(.errorView, apiResponse, apiResponse.message)
                        }
                    }
                }catch {
                    DispatchQueue.main.async {
                        completion(.noDataView, nil, "")
                    }
                }
            } else{
                completion(.noDataView, nil, msg ?? "")
            }
        }
    }
    
    func getAnalystRecommendationGetData(moduleName: String, queryData: [String: Any], completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<JSON>?, _ msg: String) ->()) {
        router.request(.analystRecommendationGetData(moduleName: moduleName, data: queryData)) { data, msg, isSuccess  in
            
            if isSuccess{
                guard let responseData = data else {
                    completion(.noDataView, nil, "")
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<JSON>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                }catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
    
    func getAnalystRecommendationPostData(moduleName: String, queryData: [String: Any], postData: [String : Any], completion: @escaping (_ success: apiSuccessType, _ response: FSAPIResponse<JSON>?, _ msg: String) ->()) {
        router.request(.analystRecommendationPostData(moduleName: moduleName, queryData: queryData, postData: postData)) { resultData, msg, isSuccess  in
            
            if isSuccess{
                guard let responseData = resultData else {
                    completion(.noDataView, nil, "")
                    
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(FSAPIResponse<JSON>.self, from: responseData)
                    if apiResponse.statuscode == APIStatusCode.ok.rawValue {
                        completion(.showDataView, apiResponse, apiResponse.message)
                    }
                    else {
                        completion(.errorView, apiResponse, apiResponse.message)
                    }
                } catch {
                    completion(.noDataView, nil, "")
                }
            }
            else{
                completion(.noDataView, nil, msg ?? self.SOMETHING_WENT_WRON)
            }
        }
    }
}
