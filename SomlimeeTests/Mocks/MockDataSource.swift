@testable import Somlimee
import Foundation

final class MockDataSource: DataSource {
    // MARK: - Call counts
    var updateUserCallCount = 0
    var getLimeTrendsDataCallCount = 0
    var getCategoryDataCallCount = 0
    var getBoardListDataCallCount = 0
    var getUserDataCallCount = 0
    var isUserLoggedInCallCount = 0
    var getQuestionsCallCount = 0
    var getBoardInfoDataCallCount = 0
    var getBoardPostMetaListCallCount = 0
    var getBoardHotPostsListCallCount = 0
    var getBoardPostMetaCallCount = 0
    var getBoardPostContentCallCount = 0
    var createPostCallCount = 0
    var writeCommentCallCount = 0
    var getCommentsCallCount = 0
    var updateAppStatesCallCount = 0
    var getAppStateCallCount = 0
    var appStatesInitCallCount = 0
    var uploadImageCallCount = 0
    var deleteUserCallCount = 0
    var voteUpPostCallCount = 0
    var createReportCallCount = 0
    var getUserPostsCallCount = 0
    var getUserCommentsCallCount = 0
    var getNotificationsCallCount = 0
    var markNotificationReadCallCount = 0

    // MARK: - Captured arguments
    var lastUpdateUserInfo: [String: Any]?
    var lastBoardInfoName: String?
    var lastBoardPostMetaListBoardName: String?
    var lastCreatePostBoardName: String?
    var lastCreatePostData: BoardPostContentData?
    var lastWriteCommentBoardName: String?
    var lastWriteCommentPostId: String?
    var lastWriteCommentText: String?
    var lastVoteUpBoardName: String?
    var lastVoteUpPostId: String?
    var lastReportBoardName: String?
    var lastReportPostId: String?
    var lastReportReason: String?

    // MARK: - Stubbed results
    var updateUserError: Error?
    var getLimeTrendsDataResult: [String: Any]?
    var getCategoryDataResult: [String: Any]?
    var getBoardListDataResult: [String: Any]?
    var getUserDataResult: [String: Any]?
    var isUserLoggedInResult: Bool = false
    var getQuestionsResult: [String: Any]?
    var getBoardInfoDataResult: [String: Any]?
    var getBoardPostMetaListResult: [[String: Any]]?
    var getBoardHotPostsListResult: [String]?
    var getBoardPostMetaResult: [String: Any]?
    var getBoardPostMetaHandler: ((String, String) -> [String: Any]?)?
    var getBoardPostContentResult: [[String: Any]]?
    var createPostError: Error?
    var writeCommentError: Error?
    var getCommentsResult: [[String: Any]]?
    var getAppStateResult: [String: Any]?
    var uploadImageResult: String = ""
    var deleteUserError: Error?
    var voteUpPostError: Error?
    var createReportError: Error?
    var getUserPostsResult: [[String: Any]]?
    var getUserCommentsResult: [[String: Any]]?
    var getNotificationsResult: [[String: Any]]?
    var markNotificationReadError: Error?
    var lastMarkNotificationReadId: String?
    var errorToThrow: Error?

    // MARK: - DataSource conformance

    func updateUser(userInfo: [String: Any]) async throws {
        updateUserCallCount += 1
        lastUpdateUserInfo = userInfo
        if let error = updateUserError ?? errorToThrow { throw error }
    }

    func getLimeTrendsData() async throws -> [String: Any]? {
        getLimeTrendsDataCallCount += 1
        if let error = errorToThrow { throw error }
        return getLimeTrendsDataResult
    }

    func getCategoryData() async throws -> [String: Any]? {
        getCategoryDataCallCount += 1
        if let error = errorToThrow { throw error }
        return getCategoryDataResult
    }

    func getBoardListData() async throws -> [String: Any]? {
        getBoardListDataCallCount += 1
        if let error = errorToThrow { throw error }
        return getBoardListDataResult
    }

    func getUserData() async throws -> [String: Any]? {
        getUserDataCallCount += 1
        if let error = errorToThrow { throw error }
        return getUserDataResult
    }

    func isUserLoggedIn() async throws -> Bool {
        isUserLoggedInCallCount += 1
        if let error = errorToThrow { throw error }
        return isUserLoggedInResult
    }

    func getQuestions() async throws -> [String: Any]? {
        getQuestionsCallCount += 1
        if let error = errorToThrow { throw error }
        return getQuestionsResult
    }

    func getBoardInfoData(boardName: String) async throws -> [String: Any]? {
        getBoardInfoDataCallCount += 1
        lastBoardInfoName = boardName
        if let error = errorToThrow { throw error }
        return getBoardInfoDataResult
    }

    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [[String: Any]]? {
        getBoardPostMetaListCallCount += 1
        lastBoardPostMetaListBoardName = boardName
        if let error = errorToThrow { throw error }
        return getBoardPostMetaListResult
    }

    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [String]? {
        getBoardHotPostsListCallCount += 1
        if let error = errorToThrow { throw error }
        return getBoardHotPostsListResult
    }

    func getBoardPostMeta(boardName: String, postId: String) async throws -> [String: Any]? {
        getBoardPostMetaCallCount += 1
        if let error = errorToThrow { throw error }
        if let handler = getBoardPostMetaHandler {
            return handler(boardName, postId)
        }
        return getBoardPostMetaResult
    }

    func getBoardPostContent(boardName: String, postId: String) async throws -> [[String: Any]]? {
        getBoardPostContentCallCount += 1
        if let error = errorToThrow { throw error }
        return getBoardPostContentResult
    }

    func createPost(boardName: String, postData: BoardPostContentData) async throws {
        createPostCallCount += 1
        lastCreatePostBoardName = boardName
        lastCreatePostData = postData
        if let error = createPostError ?? errorToThrow { throw error }
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async throws {
        writeCommentCallCount += 1
        lastWriteCommentBoardName = boardName
        lastWriteCommentPostId = postId
        lastWriteCommentText = text
        if let error = writeCommentError ?? errorToThrow { throw error }
    }

    func getComments(boardName: String, postId: String) async throws -> [[String: Any]]? {
        getCommentsCallCount += 1
        if let error = errorToThrow { throw error }
        return getCommentsResult
    }

    func updateAppStates(appStates: AppStatesData) async throws {
        updateAppStatesCallCount += 1
        if let error = errorToThrow { throw error }
    }

    func getAppState() async throws -> [String: Any]? {
        getAppStateCallCount += 1
        if let error = errorToThrow { throw error }
        return getAppStateResult
    }

    func appStatesInit() async throws {
        appStatesInitCallCount += 1
        if let error = errorToThrow { throw error }
    }

    func uploadImage(data: Data, path: String) async throws -> String {
        uploadImageCallCount += 1
        if let error = errorToThrow { throw error }
        return uploadImageResult
    }

    func deleteUser() async throws {
        deleteUserCallCount += 1
        if let error = deleteUserError ?? errorToThrow { throw error }
    }

    func voteUpPost(boardName: String, postId: String) async throws {
        voteUpPostCallCount += 1
        lastVoteUpBoardName = boardName
        lastVoteUpPostId = postId
        if let error = voteUpPostError ?? errorToThrow { throw error }
    }

    func createReport(boardName: String, postId: String, reason: String, detail: String) async throws {
        createReportCallCount += 1
        lastReportBoardName = boardName
        lastReportPostId = postId
        lastReportReason = reason
        if let error = createReportError ?? errorToThrow { throw error }
    }

    func getUserPosts(userId: String) async throws -> [[String: Any]]? {
        getUserPostsCallCount += 1
        if let error = errorToThrow { throw error }
        return getUserPostsResult
    }

    func getUserComments(userId: String) async throws -> [[String: Any]]? {
        getUserCommentsCallCount += 1
        if let error = errorToThrow { throw error }
        return getUserCommentsResult
    }

    func getNotifications(limit: Int) async throws -> [[String: Any]]? {
        getNotificationsCallCount += 1
        if let error = errorToThrow { throw error }
        return getNotificationsResult
    }

    func markNotificationRead(notificationId: String) async throws {
        markNotificationReadCallCount += 1
        lastMarkNotificationReadId = notificationId
        if let error = markNotificationReadError ?? errorToThrow { throw error }
    }
}
