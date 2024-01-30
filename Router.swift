//
//  NetworkService.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/07.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation

typealias NetworkRouterCompletion = (_ data: Data?, _ msg: String?, _ isSuccess: Bool)->()

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

enum Result<String>{
    case success
    case failure(String)
    case authenticationfailure(String)
}

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

class Router<EndPoint: EndPointType>: NetworkRouter {
    private var task: URLSessionTask?
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {

        let session = URLSession.shared
        session.configuration.httpCookieAcceptPolicy
        let iv = AES.createIv(value: "plutusfinwizardd")
        let key = "7d16b43c80ade01b".data(using: .utf8)
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                print("task is completed")
                guard  let url = response?.url,
                    let httpResponse = response as? HTTPURLResponse,
                    let fields = httpResponse.allHeaderFields as? [String: String]
                    else { return }
                
                HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
//                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
//                print("recieved  \(cookies.count) cookies")
//                HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
//                print("======================")
//                for field in fields {
//                    print("field.key: \(field.key)")
//                    print("field.value: \(field.value)")
//                }
//                print("======================")
//                for cookie in cookies {
//                    var cookieProperties = [HTTPCookiePropertyKey: Any]()
//                    cookieProperties[.name] = cookie.name
//                    cookieProperties[.value] = cookie.value
//                    cookieProperties[.domain] = cookie.domain
//                    cookieProperties[.path] = cookie.path
//                    cookieProperties[.version] = cookie.version
//                    cookieProperties[.expires] = cookie.expiresDate
//
//                    let newCookie = HTTPCookie(properties: cookieProperties)
//                    HTTPCookieStorage.shared.setCookie(newCookie!)
//
//                    print("recieved cookie name: \(cookie.name) ")
//                }
                
                var decrData: Data?
                var finalData: Data?
                do {
                    if data != nil{
                        let apiResponse = try JSONDecoder().decode(encryptOBJ.self, from: data!)
                        if (!apiResponse.enc.isEmpty) {
                            print("has encrypted response")
                            let decodedData = Data.init(base64Encoded: apiResponse.enc)
                            let aes = try AES(key: key!, iv: iv)
                            if decodedData != nil{
                                decrData = try aes.decrypt(decodedData!)
                                if decrData != nil{
                                    let decrDataString: String = String.init(data: decrData!, encoding: .utf8) ?? ""
                                    finalData = decrDataString.data(using: .utf8)
                                }
                            }
                        } else {
                            finalData = data
                        }
                    }
                } catch{
                    print("exception in data parsing")
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(nil, NetworkResponse.noData.rawValue, false)
                    }
                }
                
                if error != nil {
                    DispatchQueue.main.async {
                        completion(nil, "Please check your network connection.", false)
                    }
                }
                print("request completion")
                if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(response)
                    switch result {
                    case .success:
                        print(" result: success ")
                        completion(finalData, "", true)
                        break
                    case .failure(let networkFailureError):
                        print(" result: failure ")
                        if data != nil{
                            DispatchQueue.main.async {
                                completion(finalData, networkFailureError, true)
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                completion(finalData, networkFailureError, false)
                            }
                        }
                        break
                    case .authenticationfailure(let authenticationError):
                        print(" result: authenticationfailure ")
                        //                        HomeDataHandler.sharedInstance.logoutOnAuthInvalid()
                        
                        DispatchQueue.main.async {
                            completion(nil, authenticationError, false)
                        }
                        break
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        completion(nil, "Please check your network connection.", false)
                    }
                }
            })
        }catch {
            DispatchQueue.main.async {
                completion(nil, NetworkResponse.noData.rawValue, false)
            }
        }
        self.task?.resume()
    }
    
    
    func requestHTTPGetHtml(_ route: EndPoint, callback: @escaping (_ responseHtml: String?) -> Void) {
        let session = URLSession.shared
//        session.configuration.httpCookieAcceptPolicy
//        let iv = AES.createIv(value: "plutusfinwizardd")
//        let key = "7d16b43c80ade01b".data(using: .utf8)
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                print("task is completed")
//                guard  let url = response?.url,
//                    let httpResponse = response as? HTTPURLResponse,
//                    let fields = httpResponse.allHeaderFields as? [String: String]
//                    else {
//                        debugPrint("Failed at line 160")
//                        return }
                
//                HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
                
//                var decrData: Data?
//                var finalData: Data?
//                do {
//                    if data != nil{
//                        let apiResponse = try JSONDecoder().decode(encryptOBJ.self, from: data!)
//                        let decodedData = Data.init(base64Encoded: apiResponse.enc)
//                        let aes = try AES(key: key!, iv: iv)
//                        if decodedData != nil{
//                            decrData = try aes.decrypt(decodedData!)
//                            if decrData != nil{
//                                let decrDataString: String = String.init(data: decrData!, encoding: .utf8) ?? ""
//                                finalData = decrDataString.data(using: .utf8)
//                                debugPrint("========")
//                                debugPrint("decrDataString: \(decrDataString)")
//                                debugPrint("========")
//                            }
//                        }
//                    }
//                }
//                catch{
//                    print("exception in data parsing")
//                    callback(nil)
//                }
//
                var responseEntity: String?
                if(error == nil){
                    if let httpResponse = response as? HTTPURLResponse {
                        debugPrint("statusCode: \(httpResponse.statusCode)")
                        if (200...299).contains(httpResponse.statusCode) {
                            debugPrint("httpResponse.mimeType: \(httpResponse.mimeType)")
                            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                               let htmlData = data,
                               let htmlString = String(data: htmlData, encoding: .utf8) {
                                debugPrint("text/html response: \(htmlString)")
                                responseEntity = htmlString
                            } else {
                                debugPrint("Failed at line 198")
                            }
                        } else {
                            debugPrint("Failed at line 197")
                        }
                    } else {
                        debugPrint("Failed at line 195")
                    }
                } else {
                    debugPrint("Failed at line 194")
                }
                callback(responseEntity)
                
//                if error != nil {
//                    completion(nil)
//                }
//                print("request completion")
//                if let response = response as? HTTPURLResponse {
//                    let result = self.handleNetworkResponse(response)
//                    switch result {
//                    case .success:
//                        print(" result: success ")
//                        completion(finalData)
//                        break
//                    case .failure(let networkFailureError):
//                        print(" result: failure ")
//                        if data != nil{
//                            completion(finalData)
//                        }
//                        else{
//                            DispatchQueue.main.async {
//                                completion(finalData)
//                            }
//                        }
//                        break
//                    case .authenticationfailure(let authenticationError):
//                        print(" result: authenticationfailure ")
//                        //                        HomeDataHandler.sharedInstance.logoutOnAuthInvalid()
//
//                        DispatchQueue.main.async {
//                            completion(nil, authenticationError, false)
//                        }
//                        break
//                    }
//                }
            })
        }catch {
            callback(nil)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var finalUrl = URL(string: "")
        if route.isCompletePath {
            finalUrl = route.baseURL
        }else{
            finalUrl = route.baseURL.appendingPathComponent(route.path)
        }
        var request = URLRequest(url: finalUrl ??  route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 30.0)
        request.setValue(AppConstant.shared.getUserAgent(), forHTTPHeaderField: "User-Agent")
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
             case .request:
                   request.setValue("application/json", forHTTPHeaderField: "Content-Type")
             case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            case .multipartRequest(let bodyParameters):
                let boundary = "Boundary-\(UUID().uuidString)"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                //request.setValue(ServerInterface.getUserAgent(), forHTTPHeaderField: "User-Agent")
                let parameters: [String : String] = bodyParameters as? [String : String] ?? [:]
                request.httpBody = createDataBody(withParameters: parameters, boundary: boundary)
                
            case .multipartUploadingImageRequest(let imageData, let fileName):
                let boundary = "Boundary-\(UUID().uuidString)"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                //request.setValue(ServerInterface.getUserAgent(), forHTTPHeaderField: "User-Agent")
                request.httpBody = createDataBodyForFileUploading(boundary: boundary, imageData: imageData, fileName: fileName)
            case .requestHtml(let bodyParameters, let bodyEncoding, let urlParameters):
                debugPrint("requestHtml")
                request.httpMethod = "GET"
                request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
                do {
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                }
                catch let error {
                    debugPrint(" buildRequest error: \(error)")
                }
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    fileprivate func createDataBody(withParameters params: [String: String], boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
            for (key, value) in params {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    fileprivate func createDataBodyForFileUploading(boundary: String, imageData: Data, fileName: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        let mimetype = "image/jpg"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"res\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...399: return .success
        case 401: return .authenticationfailure(NetworkResponse.authenticationError.rawValue)
        case 402...499: return .failure(NetworkResponse.authenticationError.rawValue)
        case 500...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
