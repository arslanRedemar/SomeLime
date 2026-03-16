//
//  ReportForm.swift
//  Somlimee
//

import Foundation

enum ReportReason: String, CaseIterable {
    case spam = "spam"
    case harassment = "harassment"
    case hateSpeech = "hate_speech"
    case inappropriateContent = "inappropriate_content"
    case other = "other"

    var displayName: String {
        switch self {
        case .spam: return "스팸/광고"
        case .harassment: return "괴롭힘/욕설"
        case .hateSpeech: return "혐오 발언"
        case .inappropriateContent: return "부적절한 콘텐츠"
        case .other: return "기타"
        }
    }
}

struct ReportForm {
    let targetType: String
    let targetId: String
    let boardName: String
    let reason: ReportReason
    let detail: String
}
