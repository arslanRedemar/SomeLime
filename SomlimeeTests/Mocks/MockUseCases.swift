@testable import Somlimee
import Foundation

// MARK: - MockUCGetPost

final class MockUCGetPost: UCGetPost {
    var getPostMetaCallCount = 0
    var getPostContentCallCount = 0

    var getPostMetaResult: Result<LimeRoomPostMeta, Error> = .failure(UCGetPostFailures.EmptyData)
    var getPostContentResult: Result<LimeRoomPostContent, Error> = .failure(UCGetPostFailures.EmptyData)

    func getPostMeta(boardName: String, postId: String) async -> Result<LimeRoomPostMeta, Error> {
        getPostMetaCallCount += 1
        return getPostMetaResult
    }

    func getPostContent(boardName: String, postId: String) async -> Result<LimeRoomPostContent, Error> {
        getPostContentCallCount += 1
        return getPostContentResult
    }
}

// MARK: - MockUCWritePost

final class MockUCWritePost: UCWritePost {
    var writePostCallCount = 0
    var writePostResult: Result<Void, Error> = .success(())

    func writePost(boardName: String, postContents: LimeRoomPostContent, postMeta: LimeRoomPostMeta) async -> Result<Void, Error> {
        writePostCallCount += 1
        return writePostResult
    }
}

// MARK: - MockUCGetLimeRoomMeta

final class MockUCGetLimeRoomMeta: UCGetLimeRoomMeta {
    var getLimeRoomMetaCallCount = 0
    var getLimeRoomMetaResult: Result<LimeRoomMeta, Error> = .failure(UCGetMyLimeRoomMetaFailures.EmptyLimeRoom)

    func getLimeRoomMeta(boardName: String) async -> Result<LimeRoomMeta, Error> {
        getLimeRoomMetaCallCount += 1
        return getLimeRoomMetaResult
    }
}

// MARK: - MockUCGetLimeRoomPostList

final class MockUCGetLimeRoomPostList: UCGetLimeRoomPostList {
    var getLimeRoomPostListCallCount = 0
    var getLimeRoomPostListResult: Result<LimeRoomPostList, Error> = .failure(UCGetMyLimeRoomPostListFailures.EmptyPostList)

    func getLimeRoomPostList(boardName: String, tabName: String, counts: Int) async -> Result<LimeRoomPostList, Error> {
        getLimeRoomPostListCallCount += 1
        return getLimeRoomPostListResult
    }
}

// MARK: - MockUCGetMyLimeRoomMeta

final class MockUCGetMyLimeRoomMeta: UCGetMyLimeRoomMeta {
    var getMyLimeRoomCallCount = 0
    var getMyLimeRoomResult: Result<LimeRoomMeta, Error> = .failure(UCGetMyLimeRoomMetaFailures.EmptyLimeRoom)

    func getMyLimeRoom() async -> Result<LimeRoomMeta, Error> {
        getMyLimeRoomCallCount += 1
        return getMyLimeRoomResult
    }
}

// MARK: - MockUCGetMyLimeRoomPostList

final class MockUCGetMyLimeRoomPostList: UCGetMyLimeRoomPostList {
    var getMyLimeRoomPostListCallCount = 0
    var getMyLimeRoomPostListResult: Result<LimeRoomPostList, Error> = .failure(UCGetMyLimeRoomPostListFailures.EmptyPostList)

    func getMyLimeRoomPostList() async -> Result<LimeRoomPostList, Error> {
        getMyLimeRoomPostListCallCount += 1
        return getMyLimeRoomPostListResult
    }
}

// MARK: - MockUCGetComments

final class MockUCGetComments: UCGetComments {
    var getCommentsCallCount = 0
    var getCommentsResult: Result<[LimeRoomPostComment], Error> = .success([])

    func getComments(boardName: String, postId: String) async -> Result<[LimeRoomPostComment], Error> {
        getCommentsCallCount += 1
        return getCommentsResult
    }
}

// MARK: - MockUCSearch

final class MockUCSearch: UCSearch {
    var executeCallCount = 0
    var getAvailableBoardsCallCount = 0
    var executeResult: Result<SearchResult, Error> = .success(SearchResult(query: "", items: [], groupedByBoard: [:]))
    var getAvailableBoardsResult: Result<[String], Error> = .success([])
    var lastQuery: String?
    var lastBoardName: String?
    var lastScope: SearchScope?

    func execute(query: String, boardName: String?, scope: SearchScope) async -> Result<SearchResult, Error> {
        executeCallCount += 1
        lastQuery = query
        lastBoardName = boardName
        lastScope = scope
        return executeResult
    }

    func getAvailableBoards() async -> Result<[String], Error> {
        getAvailableBoardsCallCount += 1
        return getAvailableBoardsResult
    }
}

// MARK: - MockUCRunPsyTest

final class MockUCRunPsyTest: UCRunPsyTest {
    var loadQuestionsCallCount = 0
    var calculateResultCallCount = 0
    var saveResultCallCount = 0

    var loadQuestionsResult: Result<PersonalityTestQuestions, Error> = .failure(UCRunPsyTestFailures.questionsNotFound)
    var calculateResultReturn: PersonalityTestResultData = PersonalityTestResultData(
        Strenuousness: 0, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: "NDR"
    )
    var saveResultReturn: Result<Void, Error> = .success(())
    var lastSavedResult: PersonalityTestResultData?
    var lastSavedUid: String?

    func loadQuestions() async -> Result<PersonalityTestQuestions, Error> {
        loadQuestionsCallCount += 1
        return loadQuestionsResult
    }

    func calculateResult(answers: [Answer], categories: [Four]) -> PersonalityTestResultData {
        calculateResultCallCount += 1
        return calculateResultReturn
    }

    func saveResult(_ result: PersonalityTestResultData, uid: String) async -> Result<Void, Error> {
        saveResultCallCount += 1
        lastSavedResult = result
        lastSavedUid = uid
        return saveResultReturn
    }
}

// MARK: - MockUCWriteComment

final class MockUCWriteComment: UCWriteComment {
    var writeCommentCallCount = 0
    var writeCommentResult: Result<Void, Error> = .success(())

    func writeComment(boardName: String, postId: String, target: String, text: String) async -> Result<Void, Error> {
        writeCommentCallCount += 1
        return writeCommentResult
    }
}

// MARK: - MockUCRecommendPost

final class MockUCRecommendPost: UCRecommendPost {
    var recommendPostCallCount = 0
    var recommendPostResult: Result<Void, Error> = .success(())
    var lastBoardName: String?
    var lastPostId: String?

    func recommendPost(boardName: String, postId: String) async -> Result<Void, Error> {
        recommendPostCallCount += 1
        lastBoardName = boardName
        lastPostId = postId
        return recommendPostResult
    }
}

// MARK: - MockUCReportContent

final class MockUCReportContent: UCReportContent {
    var reportCallCount = 0
    var reportResult: Result<Void, Error> = .success(())
    var lastForm: ReportForm?

    func report(form: ReportForm) async -> Result<Void, Error> {
        reportCallCount += 1
        lastForm = form
        return reportResult
    }
}
