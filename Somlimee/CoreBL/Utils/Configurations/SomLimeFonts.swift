//
//  SomLimeFonts.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/31.
//

import SwiftUI
import UIKit

fileprivate struct HanSansNeoFont{
    static let bold = "SpoqaHanSansNeo-Bold"
    static let regular = "SpoqaHanSansNeo-Regular"
    static let thin = "SpoqaHanSansNeo-Thin"
    static let light = "SpoqaHanSansNeo-Light"
    static let medium = "SpoqaHanSansNeo-Medium"
}

extension UIFont {
    static func hanSansNeoBold(size: CGFloat) -> UIFont {
        return UIFont(name: HanSansNeoFont.bold, size: size)!
    }
    static func hanSansNeoRegular(size: CGFloat) -> UIFont {
        return UIFont(name: HanSansNeoFont.regular, size: size)!
    }
    static func hanSansNeoThin(size: CGFloat) -> UIFont {
        return UIFont(name: HanSansNeoFont.thin, size: size)!
    }
    static func hanSansNeoMedium(size: CGFloat) -> UIFont {
        return UIFont(name: HanSansNeoFont.medium, size: size)!
    }
    static func hanSansNeoLight(size: CGFloat) -> UIFont {
        return UIFont(name: HanSansNeoFont.light, size: size)!
    }
}

extension Font {
    static func hanSansNeoBold(size: CGFloat, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(HanSansNeoFont.bold, size: size, relativeTo: textStyle)
    }
    static func hanSansNeoRegular(size: CGFloat, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(HanSansNeoFont.regular, size: size, relativeTo: textStyle)
    }
    static func hanSansNeoThin(size: CGFloat, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(HanSansNeoFont.thin, size: size, relativeTo: textStyle)
    }
    static func hanSansNeoMedium(size: CGFloat, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(HanSansNeoFont.medium, size: size, relativeTo: textStyle)
    }
    static func hanSansNeoLight(size: CGFloat, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(HanSansNeoFont.light, size: size, relativeTo: textStyle)
    }
}
