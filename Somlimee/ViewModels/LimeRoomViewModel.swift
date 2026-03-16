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
        Log.vm.debug("LimeRoomViewModel.loadMeta: board=\(boardName)")
        isLoading = true
        defer { isLoading = false }
        let result = await getLimeRoomMeta.getLimeRoomMeta(boardName: boardName)
        switch result {
        case .success(let data):
            meta = data
            Log.vm.debug("LimeRoomViewModel.loadMeta: success")
        case .failure(let error):
            Log.vm.error("LimeRoomViewModel.loadMeta: failed — \(error)")
            errorMessage = "게시판 정보를 불러올 수 없습니다"
        }
    }

    func loadPostList(boardName: String, page: Int) async {
        Log.vm.debug("LimeRoomViewModel.loadPostList: board=\(boardName) page=\(page)")
        let result = await getLimeRoomPostList.getLimeRoomPostList(boardName: boardName, tabName: "", counts: 10 * (page + 1))
        switch result {
        case .success(let data):
            postList = data
            Log.vm.debug("LimeRoomViewModel.loadPostList: success — \(data.list.count) posts")
        case .failure(let error):
            Log.vm.error("LimeRoomViewModel.loadPostList: failed — \(error)")
            errorMessage = "게시글을 불러올 수 없습니다"
        }
    }

    func loadIsLoggedIn() async {
        Log.vm.debug("LimeRoomViewModel.loadIsLoggedIn: start")
        isLoggedIn = (try? await userRepo.isUserLoggedIn()) ?? false
        Log.vm.debug("LimeRoomViewModel.loadIsLoggedIn: isLoggedIn=\(self.isLoggedIn)")
    }
}
