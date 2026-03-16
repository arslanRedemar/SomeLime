//
//  BoardRegistry.swift
//  Somlimee
//

import Foundation

struct BoardRegistry {
    static let generalBoards: [String: String] = [
        "politics": "정치",
        "humor": "유머",
        "sports": "스포츠"
    ]

    static let personalityBoards: [String] = SomeLiMePTTypeDesc.typeDetail.keys.sorted()

    static let allBoards: [String] = personalityBoards + generalBoards.keys.sorted()

    static func displayName(for boardId: String) -> String {
        if let generalName = generalBoards[boardId] {
            return generalName
        }
        if let personalityName = SomeLiMePTTypeDesc.typeDetail[boardId] {
            return "\(boardId) - \(personalityName)"
        }
        return boardId
    }

    static func shortDisplayName(for boardId: String) -> String {
        if let generalName = generalBoards[boardId] {
            return generalName
        }
        return boardId
    }

    static func isPersonalityBoard(_ boardId: String) -> Bool {
        SomeLiMePTTypeDesc.typeDetail.keys.contains(boardId)
    }

    static func sfSymbol(for boardId: String) -> String? {
        switch boardId {
        case "politics": return "building.columns"
        case "humor": return "face.smiling"
        case "sports": return "sportscourt"
        default: return nil
        }
    }
}
