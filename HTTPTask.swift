//
//  HTTPTask.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/05.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String:String]

enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    case multipartRequest(bodyParameters: Parameters?)
    
    case multipartUploadingImageRequest(imageData: Data, fileName: String)
    case requestHtml(bodyParameters: Parameters?,
                     bodyEncoding: ParameterEncoding,
                     urlParameters: Parameters?)
    // case download, upload...etc
}


