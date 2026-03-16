//
//  BoardPostCommentData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/05.
//

import Foundation

struct BoardPostCommentData: Codable {
    let userName: String
    let userID: String
    let postID: String
    let target: String
    let publishedTime: String
    let isRevised: String
    let text: String
    let boardName: String

    enum CodingKeys: String, CodingKey {
        case userName = "UserName"
        case userID = "UserId"
        case postID = "PostId"
        case target = "Target"
        case publishedTime = "PublishedTime"
        case isRevised = "IsRevised"
        case text = "Text"
        case boardName = "BoardName"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        userID = try container.decodeIfPresent(String.self, forKey: .userID) ?? ""
        postID = try container.decodeIfPresent(String.self, forKey: .postID) ?? ""
        target = try container.decodeIfPresent(String.self, forKey: .target) ?? ""
        publishedTime = try container.decodeIfPresent(String.self, forKey: .publishedTime) ?? ""
        isRevised = try container.decodeIfPresent(String.self, forKey: .isRevised) ?? "No"
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        boardName = try container.decodeIfPresent(String.self, forKey: .boardName) ?? ""
    }
}
