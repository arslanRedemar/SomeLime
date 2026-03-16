@testable import Somlimee
import Foundation

// MARK: - MockUserRepository

final class MockUserRepository: UserRepository {
    var getUserDataCallCount = 0
    var isUserLoggedInCallCount = 0
    var updateNicknameCallCount = 0
    var deleteUserDataCallCount = 0

    var getUserDataResult: ProfileData?
    var isUserLoggedInResult: Bool = false
    var updateNicknameError: Error?
    var deleteUserDataError: Error?
    var lastNickname: String?
    var getUserPostsCallCount = 0
    var getUserCommentsCallCount = 0
    var getUserPostsResult: [BoardPostMetaData] = []
    var getUserCommentsResult: [BoardPostCommentData] = []
    var getUserPostsError: Error?
    var getUserCommentsError: Error?

    var createInitialProfileCallCount = 0
    var createInitialProfileError: Error?

    func getUserData() async throws -> ProfileData? {
        getUserDataCallCount += 1
        return getUserDataResult
    }

    func isUserLoggedIn() async throws -> Bool {
        isUserLoggedInCallCount += 1
        return isUserLoggedInResult
    }

    func updateNickname(_ nickname: String) async throws {
        updateNicknameCallCount += 1
        lastNickname = nickname
        if let error = updateNicknameError { throw error }
    }

    func deleteUserData() async throws {
        deleteUserDataCallCount += 1
        if let error = deleteUserDataError { throw error }
    }

    func createInitialProfile(email: String) async throws {
        createInitialProfileCallCount += 1
        if let error = createInitialProfileError { throw error }
    }

    func getUserPosts(userId: String) async throws -> [BoardPostMetaData] {
        getUserPostsCallCount += 1
        if let error = getUserPostsError { throw error }
        return getUserPostsResult
    }

    func getUserComments(userId: String) async throws -> [BoardPostCommentData] {
        getUserCommentsCallCount += 1
        if let error = getUserCommentsError { throw error }
        return getUserCommentsResult
    }
}

// MARK: - MockBoardRepository

final class MockBoardRepository: BoardRepository {
    var getBoardInfoDataCallCount = 0
    var getBoardPostMetaListCallCount = 0

    var getBoardInfoDataResult: BoardInfoData?
    var getBoardPostMetaListResult: [BoardPostMetaData]?
    var lastBoardName: String?

    func getBoardInfoData(name: String) async throws -> BoardInfoData? {
        getBoardInfoDataCallCount += 1
        lastBoardName = name
        return getBoardInfoDataResult
    }

    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [BoardPostMetaData]? {
        getBoardPostMetaListCallCount += 1
        return getBoardPostMetaListResult
    }
}

// MARK: - MockPostRepository

final class MockPostRepository: PostRepository {
    var writeBoardPostCallCount = 0
    var getBoardPostMetaCallCount = 0
    var getBoardPostContentCallCount = 0
    var getCommentsCallCount = 0
    var writeCommentCallCount = 0

    var writeBoardPostError: Error?
    var getBoardPostMetaResult: BoardPostMetaData?
    var getBoardPostContentResult: BoardPostContentData?
    var getCommentsResult: [BoardPostCommentData] = []
    var writeCommentError: Error?
    var voteUpPostCallCount = 0
    var voteUpPostError: Error?
    var uploadImageCallCount = 0
    var uploadImageResult: String = "https://example.com/image.jpg"
    var uploadImageError: Error?

    func writeBoardPost(boardName: String, postData: BoardPostContentData) async throws {
        writeBoardPostCallCount += 1
        if let error = writeBoardPostError { throw error }
    }

    func getBoardPostMeta(boardName: String, postId: String) async throws -> BoardPostMetaData? {
        getBoardPostMetaCallCount += 1
        return getBoardPostMetaResult
    }

    func getBoardPostContent(boardName: String, postId: String) async throws -> BoardPostContentData? {
        getBoardPostContentCallCount += 1
        return getBoardPostContentResult
    }

    func getComments(boardName: String, postId: String) async throws -> [BoardPostCommentData] {
        getCommentsCallCount += 1
        return getCommentsResult
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async throws {
        writeCommentCallCount += 1
        if let error = writeCommentError { throw error }
    }

    func voteUpPost(boardName: String, postId: String) async throws {
        voteUpPostCallCount += 1
        if let error = voteUpPostError { throw error }
    }

    func uploadImage(data: Data, path: String) async throws -> String {
        uploadImageCallCount += 1
        if let error = uploadImageError { throw error }
        return uploadImageResult
    }
}

// MARK: - MockBoardListRepository

final class MockBoardListRepository: BoardListRepository {
    var getBoardListDataCallCount = 0
    var getBoardListDataResult: [String]?

    func getBoardListData() async throws -> [String]? {
        getBoardListDataCallCount += 1
        return getBoardListDataResult
    }
}

// MARK: - MockCategoryRepository

final class MockCategoryRepository: CategoryRepository {
    var getCategoryDataCallCount = 0
    var getCategoryDataResult: CategoryData?

    func getCategoryData() async throws -> CategoryData? {
        getCategoryDataCallCount += 1
        return getCategoryDataResult
    }
}

// MARK: - MockRealTimeRepository

final class MockRealTimeRepository: RealTimeRepository {
    var getLimeTrendsDataCallCount = 0
    var getBoardHotPostsListCallCount = 0

    var getLimeTrendsDataResult: LimeTrendsData?
    var getBoardHotPostsListResult: [BoardPostMetaData]?

    func getLimeTrendsData() async throws -> LimeTrendsData? {
        getLimeTrendsDataCallCount += 1
        return getLimeTrendsDataResult
    }

    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [BoardPostMetaData]? {
        getBoardHotPostsListCallCount += 1
        return getBoardHotPostsListResult
    }
}

// MARK: - MockPersonalityTestRepository

final class MockPersonalityTestRepository: PersonalityTestRepository {
    var updatePersonalityTestCallCount = 0
    var getPersonalityTestResultCallCount = 0

    var getPersonalityTestResultResult: PersonalityTestResultData?

    func updatePersonalityTest(test: PersonalityTestResultData, uid: String) async throws {
        updatePersonalityTestCallCount += 1
    }

    func getPersonalityTestResult() async throws -> PersonalityTestResultData? {
        getPersonalityTestResultCallCount += 1
        return getPersonalityTestResultResult
    }
}

// MARK: - MockQuestionsRepository

final class MockQuestionsRepository: QuestionsRepository {
    var getQuestionsCallCount = 0
    var getQuestionsResult: PersonalityTestQuestions?

    func getQuestions() async throws -> PersonalityTestQuestions? {
        getQuestionsCallCount += 1
        return getQuestionsResult
    }
}

// MARK: - MockSearchRepository

final class MockSearchRepository: SearchRepository {
    var searchPostsCallCount = 0
    var getAvailableBoardsCallCount = 0

    var searchPostsResult: [SearchResultItem] = []
    var getAvailableBoardsResult: [String] = []
    var searchPostsError: Error?

    var lastSearchQuery: String?
    var lastSearchBoardName: String?
    var lastSearchScope: SearchScope?

    func searchPosts(query: String, boardName: String?, scope: SearchScope, counts: Int) async throws -> [SearchResultItem] {
        searchPostsCallCount += 1
        lastSearchQuery = query
        lastSearchBoardName = boardName
        lastSearchScope = scope
        if let error = searchPostsError { throw error }
        return searchPostsResult
    }

    func getAvailableBoards() async throws -> [String] {
        getAvailableBoardsCallCount += 1
        return getAvailableBoardsResult
    }
}

// MARK: - MockAppStateRepository

final class MockAppStateRepository: AppStateRepository {
    var appStatesInitCallCount = 0
    var updateAppStatesCallCount = 0
    var appStatesInitError: Error?
    var updateAppStatesError: Error?

    func appStatesInit() async throws {
        appStatesInitCallCount += 1
        if let error = appStatesInitError { throw error }
    }

    func updateAppStates(appStates: AppStatesData) async throws {
        updateAppStatesCallCount += 1
        if let error = updateAppStatesError { throw error }
    }
}

// MARK: - MockNotificationRepository

final class MockNotificationRepository: NotificationRepository {
    var getNotificationsCallCount = 0
    var markAsReadCallCount = 0

    var getNotificationsResult: [AppNotification] = []
    var markAsReadError: Error?
    var lastMarkAsReadId: String?

    func getNotifications(limit: Int) async throws -> [AppNotification] {
        getNotificationsCallCount += 1
        return getNotificationsResult
    }

    func markAsRead(id: String) async throws {
        markAsReadCallCount += 1
        lastMarkAsReadId = id
        if let error = markAsReadError { throw error }
    }
}

// MARK: - MockReportRepository

final class MockReportRepository: ReportRepository {
    var submitReportCallCount = 0
    var submitReportError: Error?
    var lastBoardName: String?
    var lastPostId: String?
    var lastReason: String?
    var lastDetail: String?

    func submitReport(boardName: String, postId: String, reason: String, detail: String) async throws {
        submitReportCallCount += 1
        lastBoardName = boardName
        lastPostId = postId
        lastReason = reason
        lastDetail = detail
        if let error = submitReportError { throw error }
    }
}
