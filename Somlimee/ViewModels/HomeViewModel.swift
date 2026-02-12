//
//  HomeViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/28.
//

import Foundation

protocol HomeViewModel {
    var trends: SomeLimeTrends? { get }
    var userTypeName: UserLimeTypeName? { get }
    var userStatus: UserStatus? { get }
    var myLimeRoomPostList: LimeRoomPostList? { get }
    var limeRoomList: LimeRoomList? { get }
    var psyTestList: PsyTestList? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadTrends() async
    func loadUserTypeName() async
    func loadUserStatus() async
    func loadMyLimeRoomPostsList(limeRoomName: String) async
    func loadLimeRoomList() async
    func loadPsyTestList() async
    func refreshUserStatus() async
    func setUserStatusChangeListener(_ handler: @escaping (String?) -> Void)
}

@Observable
final class HomeViewModelImpl: HomeViewModel {
    var trends: SomeLimeTrends?
    var userTypeName: UserLimeTypeName?
    var userStatus: UserStatus?
    var myLimeRoomPostList: LimeRoomPostList?
    var limeRoomList: LimeRoomList?
    var psyTestList: PsyTestList?
    var isLoading = false
    var errorMessage: String?

    private let realTimeRepo: RealTimeRepository
    private let boardRepo: BoardRepository
    private let userRepo: UserRepository
    private let authRepo: AuthRepository

    init(realTimeRepo: RealTimeRepository, boardRepo: BoardRepository, userRepo: UserRepository, authRepo: AuthRepository) {
        self.realTimeRepo = realTimeRepo
        self.boardRepo = boardRepo
        self.userRepo = userRepo
        self.authRepo = authRepo
    }

    func loadTrends() async {
        do {
            let data = try await realTimeRepo.getLimeTrendsData()
            trends = data.map { SomeLimeTrends(list: $0.trendsList) }
        } catch {
            errorMessage = "트렌드를 불러올 수 없습니다"
        }
    }

    func loadUserTypeName() async {
        do {
            let profile = try await userRepo.getUserData()
            userTypeName = profile.map { UserLimeTypeName(name: $0.personalityType) }
        } catch {
            errorMessage = "사용자 정보를 불러올 수 없습니다"
        }
    }

    func loadUserStatus() async {
        let loggedIn = (try? await userRepo.isUserLoggedIn()) ?? false
        userStatus = UserStatus(isLoggedIn: loggedIn)
    }

    func loadMyLimeRoomPostsList(limeRoomName: String) async {
        do {
            guard let data = try await boardRepo.getBoardPostMetaList(boardName: limeRoomName, startTime: "NaN", counts: 5) else { return }
            let list = data.map { LimeRoomPostMeta(userID: $0.userID, userName: $0.userName, title: $0.postTitle, views: $0.numberOfViews, publishedTime: $0.publishedTime, numOfVotes: $0.numberOfVoteUps, numOfComments: $0.numberOfComments, numOfViews: $0.numberOfViews, postID: $0.postID, boardPostTap: $0.boardTap, boardName: $0.boardID) }
            myLimeRoomPostList = LimeRoomPostList(list: list)
        } catch {
            errorMessage = "게시글을 불러올 수 없습니다"
        }
    }

    func loadLimeRoomList() async {
        limeRoomList = LimeRoomList(list: SomeLiMePTTypeDesc.typeDetail.keys.sorted())
    }

    func loadPsyTestList() async {
        psyTestList = PsyTestList(list: SomeLiMePTTypeDesc.typeDetail.keys.sorted())
    }

    func refreshUserStatus() async {
        try? await authRepo.reloadCurrentUser()
        await loadUserStatus()
    }

    func setUserStatusChangeListener(_ handler: @escaping (String?) -> Void) {
        authRepo.addAuthStateListener(handler)
    }
}
