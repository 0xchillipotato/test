//
//  JSONEncoding.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/05.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation

struct JSONParameterEncoder: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            let iv = AES.createIv(value: "plutusfinwizardd")
            let key = "7d16b43c80ade01b".data(using: .utf8)
            let aes = try AES(key: key!, iv: iv)
            let encrypted = try aes.encrypt(jsonAsData)
            let dict:[String: Any] = ["_encr_payload": encrypted.base64EncodedString()]
            let json1AsData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            urlRequest.httpBody = json1AsData
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }catch {
            throw NetworkError.encodingFailed
        }
    }
}

