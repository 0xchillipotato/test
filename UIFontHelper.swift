//
//  UIFontHelper.swift
//  FisdomSDK
//
//  Created by Raghu Eswar on 20/06/22.
//  Copyright © 2022 Abhishek Mishra. All rights reserved.
//

import Foundation

class UIFontHelper {
    public static let RUBIC_FONTS = ["Rubik-Black",
                                     "Rubik-BlackItali",
                                     "Rubik-Bold",
                                     "Rubik-BoldItalic",
                                     "Rubik-ExtraBold",
                                     "Rubik-ExtraBoldItalic",
                                     "Rubik-Italic",
                                     "Rubik-Light",
                                     "Rubik-LightItalic",
                                     "Rubik-Medium",
                                     "Rubik-MediumItalic",
                                     "Rubik-Regular",
                                     "Rubik-SemiBold",
                                     "Rubik-SemiBoldItalic", ]
    public static let FONT_FILE_TYPE = ".ttf"
    static func registerFonts() {
        print(#function)
        RUBIC_FONTS.forEach { fileName
            in
            let frameworkBundle = Bundle(for: UIFontHelper.self)
            guard let fontFileURL = frameworkBundle.path(forResource: fileName, ofType: FONT_FILE_TYPE) else {
                print(RegisterFontError.fontPathNotFound)
                return
            }
            guard let fontData = NSData(contentsOfFile: fontFileURL), let dataProvider = CGDataProvider.init(data: fontData) else {
                print(RegisterFontError.invalidFontFile)
                return
            }
            guard let cgFont = CGFont.init(dataProvider) else {
                print(RegisterFontError.invalidFontFile)
                return
            }
            var errorRef: Unmanaged<CFError>? = nil
            guard CTFontManagerRegisterGraphicsFont(cgFont, &errorRef) else   {
                print(RegisterFontError.invalidFontFile)
                return
            }
        }
    }
    
}

enum RegisterFontError: Error {
    case invalidFontFile
    case fontPathNotFound
    case initFontError
    case registerFailed
}
