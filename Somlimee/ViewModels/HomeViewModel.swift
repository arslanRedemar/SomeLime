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
        Log.vm.debug("HomeViewModel.loadTrends: start")
        do {
            let data = try await realTimeRepo.getLimeTrendsData()
            trends = data.map { SomeLimeTrends(list: $0.trendsList) }
            Log.vm.debug("HomeViewModel.loadTrends: success — \(self.trends?.list.count ?? 0) trends")
        } catch {
            Log.vm.error("HomeViewModel.loadTrends: failed — \(error)")
            errorMessage = "트렌드를 불러올 수 없습니다"
        }
    }

    func loadUserTypeName() async {
        Log.vm.debug("HomeViewModel.loadUserTypeName: start")
        do {
            let profile = try await userRepo.getUserData()
            userTypeName = profile.map { UserLimeTypeName(name: $0.personalityType) }
            Log.vm.debug("HomeViewModel.loadUserTypeName: success — \(self.userTypeName?.name ?? "nil")")
        } catch {
            Log.vm.error("HomeViewModel.loadUserTypeName: failed — \(error)")
            errorMessage = "사용자 정보를 불러올 수 없습니다"
        }
    }

    func loadUserStatus() async {
        Log.vm.debug("HomeViewModel.loadUserStatus: start")
        let loggedIn = (try? await userRepo.isUserLoggedIn()) ?? false
        userStatus = UserStatus(isLoggedIn: loggedIn)
        Log.vm.debug("HomeViewModel.loadUserStatus: isLoggedIn=\(loggedIn)")

        // Ensure Users/{uid} document exists for legacy accounts
        if loggedIn {
            let profile = try? await userRepo.getUserData()
            if profile == nil, let email = authRepo.currentUserEmail {
                Log.vm.info("HomeViewModel.loadUserStatus: creating missing user document")
                try? await userRepo.createInitialProfile(email: email)
            }
        }
    }

    func loadMyLimeRoomPostsList(limeRoomName: String) async {
        Log.vm.debug("HomeViewModel.loadMyLimeRoomPostsList: board=\(limeRoomName)")
        do {
            guard let data = try await boardRepo.getBoardPostMetaList(boardName: limeRoomName, startTime: nil, counts: 5) else { return }
            let list = data.map { LimeRoomPostMeta(userID: $0.userID, userName: $0.userName, title: $0.postTitle, views: $0.numberOfViews, publishedTime: $0.publishedTime, numOfVotes: $0.numberOfVoteUps, numOfComments: $0.numberOfComments, numOfViews: $0.numberOfViews, postID: $0.postID, boardPostTap: $0.boardTap, boardName: $0.boardID) }
            myLimeRoomPostList = LimeRoomPostList(list: list)
            Log.vm.debug("HomeViewModel.loadMyLimeRoomPostsList: success — \(list.count) posts")
        } catch {
            Log.vm.error("HomeViewModel.loadMyLimeRoomPostsList: failed — \(error)")
            errorMessage = "게시글을 불러올 수 없습니다"
        }
    }

    func loadLimeRoomList() async {
        Log.vm.debug("HomeViewModel.loadLimeRoomList: start")
        limeRoomList = LimeRoomList(list: BoardRegistry.allBoards)
        Log.vm.debug("HomeViewModel.loadLimeRoomList: loaded \(self.limeRoomList?.list.count ?? 0) rooms")
    }

    func loadPsyTestList() async {
        Log.vm.debug("HomeViewModel.loadPsyTestList: start")
        psyTestList = PsyTestList(list: SomeLiMePTTypeDesc.typeDetail.keys.sorted())
        Log.vm.debug("HomeViewModel.loadPsyTestList: loaded \(self.psyTestList?.list.count ?? 0) tests")
    }

    func refreshUserStatus() async {
        Log.vm.debug("HomeViewModel.refreshUserStatus: start")
        try? await authRepo.reloadCurrentUser()
        await loadUserStatus()
    }

    func setUserStatusChangeListener(_ handler: @escaping (String?) -> Void) {
        authRepo.addAuthStateListener(handler)
    }
}
