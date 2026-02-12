//
//  BoardViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/14.
//

import Foundation

protocol LimeRoomViewModel {
    var meta: LimeRoomMeta? { get }
    var postList: LimeRoomPostList? { get }
    var isLoggedIn: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadMeta(boardName: String) async
    func loadPostList(boardName: String, page: Int) async
    func loadIsLoggedIn() async
}

@Observable
final class LimeRoomViewModelImpl: LimeRoomViewModel {
    var meta: LimeRoomMeta?
    var postList: LimeRoomPostList?
    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?

    private let getLimeRoomMeta: UCGetLimeRoomMeta
    private let getLimeRoomPostList: UCGetLimeRoomPostList
    private let userRepo: UserRepository

    init(getLimeRoomMeta: UCGetLimeRoomMeta, getLimeRoomPostList: UCGetLimeRoomPostList, userRepo: UserRepository) {
        self.getLimeRoomMeta = getLimeRoomMeta
        self.getLimeRoomPostList = getLimeRoomPostList
        self.userRepo = userRepo
    }

    func loadMeta(boardName: String) async {
        isLoading = true
        defer { isLoading = false }
        let result = await getLimeRoomMeta.getLimeRoomMeta(boardName: boardName)
        switch result {
        case .success(let data): meta = data
        case .failure: errorMessage = "게시판 정보를 불러올 수 없습니다"
        }
    }

    func loadPostList(boardName: String, page: Int) async {
        let result = await getLimeRoomPostList.getLimeRoomPostList(boardName: boardName, tabName: "", counts: 10 * (page + 1))
        switch result {
        case .success(let data): postList = data
        case .failure: errorMessage = "게시글을 불러올 수 없습니다"
        }
    }

    func loadIsLoggedIn() async {
        isLoggedIn = (try? await userRepo.isUserLoggedIn()) ?? false
    }
}
