//
//  BoardInfoData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/29.
//

import Foundation

struct BoardInfoData: Codable {
    var boardName: String
    let boardOwnerID: String
    let tapList: [String]
    let boardLevel: Int
    let boardDescription: String
    let boardHotKeyword: [String]

    enum CodingKeys: String, CodingKey {
        case boardName
        case boardOwnerID = "BoardOwnerId"
        case tapList = "BoardTapList"
        case boardLevel = "BoardLevel"
        case boardDescription = "BoardDescription"
        case boardHotKeyword = "BoardHotKeywords"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        boardName = try container.decodeIfPresent(String.self, forKey: .boardName) ?? ""
        boardOwnerID = try container.decode(String.self, forKey: .boardOwnerID)
        tapList = try container.decode([String].self, forKey: .tapList)
        boardLevel = try container.decode(Int.self, forKey: .boardLevel)
        boardDescription = try container.decode(String.self, forKey: .boardDescription)
        boardHotKeyword = try container.decodeIfPresent([String].self, forKey: .boardHotKeyword) ?? []
    }

    init(boardName: String, boardOwnerID: String, tapList: [String], boardLevel: Int, boardDescription: String, boardHotKeyword: [String]) {
        self.boardName = boardName
        self.boardOwnerID = boardOwnerID
        self.tapList = tapList
        self.boardLevel = boardLevel
        self.boardDescription = boardDescription
        self.boardHotKeyword = boardHotKeyword
    }
}
