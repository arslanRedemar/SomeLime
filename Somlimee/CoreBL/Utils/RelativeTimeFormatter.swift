//
//  RelativeTimeFormatter.swift
//  Somlimee
//

import Foundation

enum RelativeTimeFormatter {

    /// Converts a publishedTime string to a Korean relative time string.
    /// - "방금" for < 1 minute
    /// - "N분 전" for 1-59 minutes
    /// - "N시간 전" for 1-23 hours
    /// - "M월 D일" for >= 24 hours
    static func string(from publishedTime: String) -> String {
        let now = Date()

        // Try ISO8601 first, then common Firestore formats
        let formatters: [DateFormatter] = {
            let iso = DateFormatter()
            iso.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            iso.locale = Locale(identifier: "en_US_POSIX")

            let isoFrac = DateFormatter()
            isoFrac.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            isoFrac.locale = Locale(identifier: "en_US_POSIX")

            let space = DateFormatter()
            space.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            space.locale = Locale(identifier: "en_US_POSIX")

            let simple = DateFormatter()
            simple.dateFormat = "yyyy-MM-dd HH:mm:ss"
            simple.locale = Locale(identifier: "en_US_POSIX")

            let dateOnly = DateFormatter()
            dateOnly.dateFormat = "yyyy-MM-dd"
            dateOnly.locale = Locale(identifier: "en_US_POSIX")

            return [iso, isoFrac, space, simple, dateOnly]
        }()

        var date: Date?
        for formatter in formatters {
            if let d = formatter.date(from: publishedTime) {
                date = d
                break
            }
        }

        guard let parsed = date else {
            // Fallback: return the raw string truncated
            return String(publishedTime.prefix(10))
        }

        let seconds = Int(now.timeIntervalSince(parsed))

        if seconds < 60 {
            return "방금"
        } else if seconds < 3600 {
            return "\(seconds / 60)분 전"
        } else if seconds < 86400 {
            return "\(seconds / 3600)시간 전"
        } else {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: parsed)
            let day = calendar.component(.day, from: parsed)
            return "\(month)월 \(day)일"
        }
    }
}
