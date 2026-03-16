//
//  BoardFeedData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/19.
//

import Foundation

enum PostType: String, Codable {
    case image
    case video
    case text

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PostType(rawValue: rawValue) ?? .text
    }
}

struct BoardPostMetaData: Codable {
    var boardID: String
    let postID: String
    let publishedTime: String
    let postType: PostType
    let postTitle: String
    let boardTap: String
    let userID: String
    let userName: String
    let numberOfViews: Int
    let numberOfVoteUps: Int
    let numberOfComments: Int

    enum CodingKeys: String, CodingKey {
        case boardID
        case postID = "PostId"
        case publishedTime = "PublishedTime"
        case postType = "PostType"
        case postTitle = "PostTitle"
        case boardTap = "BoardTap"
        case userID = "UserId"
        case userName = "UserName"
        case numberOfViews = "Views"
        case numberOfVoteUps = "VoteUps"
        case numberOfComments = "CommentsNumber"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        boardID = try container.decodeIfPresent(String.self, forKey: .boardID) ?? ""
        postID = try container.decodeIfPresent(String.self, forKey: .postID) ?? ""
        publishedTime = try container.decodeIfPresent(String.self, forKey: .publishedTime) ?? "NaN"
        postType = try container.decodeIfPresent(PostType.self, forKey: .postType) ?? .text
        postTitle = try container.decodeIfPresent(String.self, forKey: .postTitle) ?? ""
        boardTap = try container.decodeIfPresent(String.self, forKey: .boardTap) ?? ""
        userID = try container.decodeIfPresent(String.self, forKey: .userID) ?? ""
        userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        numberOfViews = try container.decodeIfPresent(Int.self, forKey: .numberOfViews) ?? 0
        numberOfVoteUps = try container.decodeIfPresent(Int.self, forKey: .numberOfVoteUps) ?? 0
        numberOfComments = try container.decodeIfPresent(Int.self, forKey: .numberOfComments) ?? 0
    }

    init(boardID: String, postID: String, publishedTime: String, postType: PostType, postTitle: String, boardTap: String, userID: String, userName: String, numberOfViews: Int, numberOfVoteUps: Int, numberOfComments: Int) {
        self.boardID = boardID
        self.postID = postID
        self.publishedTime = publishedTime
        self.postType = postType
        self.postTitle = postTitle
        self.boardTap = boardTap
        self.userID = userID
        self.userName = userName
        self.numberOfViews = numberOfViews
        self.numberOfVoteUps = numberOfVoteUps
        self.numberOfComments = numberOfComments
    }
}
