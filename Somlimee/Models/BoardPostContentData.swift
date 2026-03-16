//
//  BoardPostContentData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/01.
//

import Foundation

struct BoardPostContentData: Codable {
    let boardPostTap: String
    let boardPostUserId: String
    let boardPostTitle: String
    let boardPostParagraph: String
    let boardPostImageURLs: [String]
    let boardPostComments: [BoardPostCommentData]
}
