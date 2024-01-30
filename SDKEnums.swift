//
//  SDKEnums.swift
//  FisdomSdk
//
//  Created by Abhishek Mishra on 11/10/18.
//  Copyright © 2018 Abhishek Mishra. All rights reserved.
//

import Foundation

enum APIStatusCode: Int{
    case networkError = -2,
    unknownError = -1,
    ok = 200,
    notenrolled = 301,
    docPending = 302,
    enrollPending = 303,
    bankUnsupported = 304,
    genricError = 400,
    unAuthorized = 401,
    AlreadyRegistered = 402,
    loginRequired = 403,
    serverDown = 405,
    verificationPending = 410,
    InvalidCredentials = 411,
    loginFailed = 412,
    emailNotVerified = 413,
    NotRregistered = 414
}

enum apiSuccessType: Int{
    case showDataView = 0, noDataView, errorView
}

enum docType: Int{
    case image = 0, video, sign
}
