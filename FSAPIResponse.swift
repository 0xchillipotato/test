//
//  FSAPIResponse.swift
//  Fisdom
//
//  Created by Abhishek Mishra on 14/06/18.
//  Copyright © 2018 finwzard. All rights reserved.
//

import Foundation

struct FSAPIResponse<T: Decodable>{
    var message: String = ""
    var response: FSResponse<T>?
    var statuscode: Int = 0
    var time: String = ""
    var userId: Int = 0
    var uTime: String = ""
}

extension FSAPIResponse: Decodable {
    
    private enum ResponseCodingKeys: String, CodingKey {
        case message = "pfwmessage"
        case response = "pfwresponse"
        case statuscode = "pfwstatus_code"
        case time = "pfwtime"
        case userId = "pfwuser_id"
        case uTime = "pfwutime"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResponseCodingKeys.self)
        
        if let message = try container.decodeIfPresent(String.self, forKey: .message){
            self.message = message
        }
        if let response = try container.decodeIfPresent(FSResponse<T>.self, forKey: .response){
            self.response = response
        }
        if let statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode){
            self.statuscode = statuscode
        }
        if let time = try container.decodeIfPresent(String.self, forKey: .time){
            self.time = time
        }
        if let userId = try container.decodeIfPresent(Int.self, forKey: .userId){
            self.userId = userId
        }
        if let uTime = try container.decodeIfPresent(String.self, forKey: .uTime){
            self.uTime = uTime
        }
    }
}

struct FSResponse<T: Decodable> {
    var requestApi: String = ""
    var result: T?
    var statusCode: Int = 0
}

extension FSResponse: Decodable {
    
    private enum ResponseCodingKeys: String, CodingKey {
        case requestApi = "requestapi"
        case result = "result"
        case statusCode = "status_code"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResponseCodingKeys.self)
        
        if let requestApi = try container.decodeIfPresent(String.self, forKey: .requestApi){
            self.requestApi = requestApi
        }
        if let result = try container.decodeIfPresent(T.self, forKey: .result){
            self.result = result
        }
        if let statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode){
            self.statusCode = statusCode
        }
    }
}
