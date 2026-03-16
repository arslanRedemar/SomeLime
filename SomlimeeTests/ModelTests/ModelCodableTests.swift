@testable import Somlimee
import XCTest

final class ModelCodableTests: XCTestCase {

    // MARK: - AppStatesData

    func testAppStatesDataRoundTrip() throws {
        let original = AppStatesData(isFirstTimeLaunched: true, isNeedToUpdateLocalDataSource: false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppStatesData.self, from: data)
        XCTAssertEqual(decoded.isFirstTimeLaunched, true)
        XCTAssertEqual(decoded.isNeedToUpdateLocalDataSource, false)
    }

    // MARK: - BoardInfoData

    func testBoardInfoDataRoundTrip() throws {
        let original = TestFixtures.makeBoardInfoData()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BoardInfoData.self, from: data)
        XCTAssertEqual(decoded.boardOwnerID, "owner1")
        XCTAssertEqual(decoded.tapList, ["General", "Hot"])
        XCTAssertEqual(decoded.boardLevel, 1)
    }

    func testBoardInfoDataFromDict() throws {
        let dict = TestFixtures.makeBoardInfoDict()
        let decoded = try DictionaryDecoder.decode(BoardInfoData.self, from: dict)
        XCTAssertEqual(decoded.boardOwnerID, "owner1")
        XCTAssertEqual(decoded.boardDescription, "Test Description")
    }

    // MARK: - BoardPostMetaData

    func testBoardPostMetaDataRoundTrip() throws {
        let original = TestFixtures.makeBoardPostMetaData()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BoardPostMetaData.self, from: data)
        XCTAssertEqual(decoded.postID, "post1")
        XCTAssertEqual(decoded.postTitle, "Test Post")
        XCTAssertEqual(decoded.numberOfViews, 10)
    }

    func testBoardPostMetaDataFromDict() throws {
        let dict = TestFixtures.makeBoardPostMetaDict()
        let decoded = try DictionaryDecoder.decode(BoardPostMetaData.self, from: dict)
        XCTAssertEqual(decoded.postID, "post1")
        XCTAssertEqual(decoded.postTitle, "Test Post")
        XCTAssertEqual(decoded.userID, "user1")
    }

    func testBoardPostMetaDataDefaults() throws {
        let dict: [String: Any] = [:]
        let decoded = try DictionaryDecoder.decode(BoardPostMetaData.self, from: dict)
        XCTAssertEqual(decoded.boardID, "")
        XCTAssertEqual(decoded.postID, "")
        XCTAssertEqual(decoded.publishedTime, "NaN")
        XCTAssertEqual(decoded.postType, .text)
        XCTAssertEqual(decoded.numberOfViews, 0)
    }

    // MARK: - PostType

    func testPostTypeDecodesKnownValues() throws {
        for type in ["image", "video", "text"] {
            let json = "\"\(type)\"".data(using: .utf8)!
            let decoded = try JSONDecoder().decode(PostType.self, from: json)
            XCTAssertEqual(decoded.rawValue, type)
        }
    }

    func testPostTypeDefaultsToText() throws {
        let json = "\"unknown\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(PostType.self, from: json)
        XCTAssertEqual(decoded, .text)
    }

    // MARK: - BoardPostContentData

    func testBoardPostContentDataRoundTrip() throws {
        let original = TestFixtures.makeBoardPostContentData()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BoardPostContentData.self, from: data)
        XCTAssertEqual(decoded.boardPostTitle, "Test Post")
        XCTAssertEqual(decoded.boardPostParagraph, "Test paragraph")
    }

    // MARK: - BoardPostCommentData

    func testBoardPostCommentDataRoundTrip() throws {
        let original = TestFixtures.makeBoardPostCommentData()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BoardPostCommentData.self, from: data)
        XCTAssertEqual(decoded.userName, "TestUser")
        XCTAssertEqual(decoded.text, "Test comment")
    }

    func testBoardPostCommentDataFromDict() throws {
        let dict = TestFixtures.makeBoardPostCommentDict()
        let decoded = try DictionaryDecoder.decode(BoardPostCommentData.self, from: dict)
        XCTAssertEqual(decoded.userName, "TestUser")
        XCTAssertEqual(decoded.userID, "user1")
        XCTAssertEqual(decoded.isRevised, "No")
    }

    // MARK: - CategoryData

    func testCategoryDataRoundTrip() throws {
        let original = CategoryData(list: ["A", "B"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CategoryData.self, from: data)
        XCTAssertEqual(decoded.list, ["A", "B"])
    }

    // MARK: - LimeTrendsData

    func testLimeTrendsDataRoundTrip() throws {
        let original = LimeTrendsData(trendsList: ["t1", "t2"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(LimeTrendsData.self, from: data)
        XCTAssertEqual(decoded.trendsList, ["t1", "t2"])
    }

    func testLimeTrendsDataFromDict() throws {
        let dict = TestFixtures.makeLimeTrendsDict()
        let decoded = try DictionaryDecoder.decode(LimeTrendsData.self, from: dict)
        XCTAssertEqual(decoded.trendsList, ["trend1", "trend2"])
    }

    // MARK: - PersonalityTestResultData

    func testPersonalityTestResultDataRoundTrip() throws {
        let original = TestFixtures.makePersonalityTestResult()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersonalityTestResultData.self, from: data)
        XCTAssertEqual(decoded.Strenuousness, 10)
        XCTAssertEqual(decoded.Receptiveness, 20)
        XCTAssertEqual(decoded.Harmonization, 30)
        XCTAssertEqual(decoded.Coagulation, 40)
        XCTAssertEqual(decoded.type, "SDD")
    }

    // MARK: - ProfileData

    func testProfileDataRoundTrip() throws {
        let original = TestFixtures.makeProfileData()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ProfileData.self, from: data)
        XCTAssertEqual(decoded.userName, "TestUser")
        XCTAssertEqual(decoded.personalityType, "SDD")
        XCTAssertEqual(decoded.personalityTestResult.Strenuousness, 10)
    }

    func testProfileDataFromDict() throws {
        let dict = TestFixtures.makeProfileDict()
        let decoded = try DictionaryDecoder.decode(ProfileData.self, from: dict)
        XCTAssertEqual(decoded.userName, "TestUser")
        XCTAssertEqual(decoded.personalityType, "SDD")
        XCTAssertEqual(decoded.personalityTestResult.Strenuousness, 10)
        XCTAssertEqual(decoded.personalityTestResult.Coagulation, 40)
    }

    // MARK: - BoardHotKeyData

    func testBoardHotKeyDataRoundTrip() throws {
        let original = BoardHotKeyData(boardHotkeywordsList: ["kw1", "kw2"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BoardHotKeyData.self, from: data)
        XCTAssertEqual(decoded.boardHotkeywordsList, ["kw1", "kw2"])
    }

    // MARK: - HotBoardRankingData

    func testHotBoardRankingDataRoundTrip() throws {
        let original = HotBoardRankingData(realTimeBoardRanking: ["board1", "board2"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HotBoardRankingData.self, from: data)
        XCTAssertEqual(decoded.realTimeBoardRanking, ["board1", "board2"])
    }

    // MARK: - SearchHistoryData

    func testSearchHistoryDataRoundTrip() throws {
        let original = SearchHistoryData(history: ["search1"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SearchHistoryData.self, from: data)
        XCTAssertEqual(decoded.history, ["search1"])
    }

    // MARK: - SearchRealTimeData

    func testSearchRealTimeDataRoundTrip() throws {
        let meta = TestFixtures.makeBoardPostMetaData()
        let original = SearchRealTimeData(SearchRealTimePosts: [meta])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SearchRealTimeData.self, from: data)
        XCTAssertEqual(decoded.SearchRealTimePosts.count, 1)
        XCTAssertEqual(decoded.SearchRealTimePosts[0].postID, "post1")
    }
}
