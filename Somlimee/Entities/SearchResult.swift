//
//  SearchResult.swift
//  Somlimee
//

import Foundation

enum SearchScope {
    case title
    case content
    case titleAndContent
}

struct SearchResultItem {
    let postMeta: LimeRoomPostMeta
    let boardDisplayName: String
}

struct SearchResult {
    let query: String
    let items: [SearchResultItem]
    let groupedByBoard: [String: [SearchResultItem]]
}
