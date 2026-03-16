//
//  LimeTrendsData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import Foundation

struct LimeTrendsData: Codable {
    let trendsList: [String]

    enum CodingKeys: String, CodingKey {
        case trendsList = "List"
    }
}
