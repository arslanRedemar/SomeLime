//
//  SomLimeColors.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/31.
//
//  Blue Palette
//  ─────────────────────────────────────────
//  primary       #3B82F6 / #60A5FA  Blue        — 버튼, CTA, 브랜드
//  darkPrimary   #1E3A8A / #93C5FD  Deep Navy   — 헤더, 강조
//  lightPrimary  #DBEAFE / #1E293B  Pale Blue   — 배경 틴트, 카드
//  secondary     #0D9488 / #2DD4BF  Teal        — 보조 액센트
//  background    #FFFFFF / #0F172A  White/Slate — 메인 배경
//  systemGray    #E2E8F0 / #334155  Slate Gray  — 디바이더, 보더
//  label         #0F172A / #F1F5F9  Slate/Ice   — 텍스트
//

import SwiftUI
import UIKit

// MARK: - UIKit Colors

enum SomLimeColors {
    static let primaryColor: UIColor = UIColor(named: "primaryColor")!
    static let darkPrimaryColor: UIColor = UIColor(named: "darkPrimaryColor")!
    static let lightPrimaryColor: UIColor = UIColor(named: "lightPrimaryColor")!
    static let secondaryColor: UIColor = UIColor(named: "secondaryColor")!
    static let systemGrayLight: UIColor = UIColor(named: "systemGrayLight")!
    static let backgroundColor: UIColor = UIColor(named: "backgroundColor")!
    static let labelLight: UIColor = UIColor(named: "white")!
    static let labelDark: UIColor = UIColor(named: "black")!
    static let label: UIColor = UIColor(named: "label")!
}

// MARK: - SwiftUI Colors

extension Color {
    // Brand
    static let somLimePrimary = Color("primaryColor")
    static let somLimeDarkPrimary = Color("darkPrimaryColor")
    static let somLimeLightPrimary = Color("lightPrimaryColor")
    static let somLimeSecondary = Color("secondaryColor")

    // Neutrals
    static let somLimeSystemGray = Color("systemGrayLight")
    static let somLimeBackground = Color("backgroundColor")
    static let somLimeGroupedBackground = Color("lightPrimaryColor")

    // Text
    static let somLimeLabel = Color("label")
    static let somLimeLabelLight = Color("white")
    static let somLimeLabelDark = Color("black")
    static let somLimeSecondaryLabel = Color.secondary
}
