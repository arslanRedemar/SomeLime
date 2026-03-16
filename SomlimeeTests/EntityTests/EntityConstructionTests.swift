@testable import Somlimee
import XCTest

final class EntityConstructionTests: XCTestCase {

    func testAppStates() {
        let sut = AppStates(isFirstTimeLaunched: true, isNeedToUpdateLocalDataSource: false)
        XCTAssertTrue(sut.isFirstTimeLaunched)
        XCTAssertFalse(sut.isNeedToUpdateLocalDataSource)
    }

    func testLimeRoomList() {
        let sut = LimeRoomList(list: ["Room1", "Room2"])
        XCTAssertEqual(sut.list.count, 2)
        XCTAssertEqual(sut.list[0], "Room1")
    }

    func testLimeRoomMeta() {
        let sut = LimeRoomMeta(limeRoomName: "Room", limeRoomDescription: "Desc", limeRoomTabs: ["Tab1"], limeRoomImageName: "img")
        XCTAssertEqual(sut.limeRoomName, "Room")
        XCTAssertEqual(sut.limeRoomDescription, "Desc")
        XCTAssertEqual(sut.limeRoomTabs, ["Tab1"])
        XCTAssertEqual(sut.limeRoomImageName, "img")
    }

    func testLimeRoomPostComment() {
        let sut = LimeRoomPostComment(userName: "User", userID: "u1", postID: "p1", target: "", publishedTime: "2024", isRevised: false, text: "Hello", boardName: "SDR")
        XCTAssertEqual(sut.userName, "User")
        XCTAssertEqual(sut.userID, "u1")
        XCTAssertEqual(sut.postID, "p1")
        XCTAssertFalse(sut.isRevised)
        XCTAssertEqual(sut.text, "Hello")
    }

    func testLimeRoomPostContent() {
        let sut = LimeRoomPostContent(paragraph: "Text", imageURLs: ["url1"], imgLocation: [0], comments: [])
        XCTAssertEqual(sut.paragraph, "Text")
        XCTAssertEqual(sut.imageURLs, ["url1"])
        XCTAssertEqual(sut.imgLocation, [0])
        XCTAssertTrue(sut.comments.isEmpty)
    }

    func testLimeRoomPostList() {
        let meta = TestFixtures.makeLimeRoomPostMeta()
        let sut = LimeRoomPostList(list: [meta])
        XCTAssertEqual(sut.list.count, 1)
    }

    func testLimeRoomPostMeta() {
        let sut = LimeRoomPostMeta(userID: "u1", userName: "User", title: "Title", views: 5, publishedTime: "2024", numOfVotes: 1, numOfComments: 2, numOfViews: 5, postID: "p1", boardPostTap: "General", boardName: "board1")
        XCTAssertEqual(sut.userID, "u1")
        XCTAssertEqual(sut.title, "Title")
        XCTAssertEqual(sut.views, 5)
        XCTAssertEqual(sut.postID, "p1")
        XCTAssertEqual(sut.boardName, "board1")
    }

    func testLimeTestQnAPairs() {
        let sut = LimeTestQnAPairs(questions: ["Q1", "Q2"], answerChoices: ["A", "B"])
        XCTAssertEqual(sut.questions.count, 2)
        XCTAssertEqual(sut.answerChoices.count, 2)
    }

    func testLimeTestReport() {
        let sut = LimeTestReport(typeName: "SDD", typeDetailedReport: "Report", typeImageName: "img")
        XCTAssertEqual(sut.typeName, "SDD")
        XCTAssertEqual(sut.typeDetailedReport, "Report")
    }

    func testLimeTestResult() {
        let sut = LimeTestResult(str: 10, rec: 20, har: 30, coa: 40, typeName: "SDD", typeDesc: "Desc")
        XCTAssertEqual(sut.str, 10)
        XCTAssertEqual(sut.rec, 20)
        XCTAssertEqual(sut.har, 30)
        XCTAssertEqual(sut.coa, 40)
        XCTAssertEqual(sut.typeName, "SDD")
    }

    func testMenuList() {
        let sut = MenuList(list: ["Menu1", "Menu2"])
        XCTAssertEqual(sut.list, ["Menu1", "Menu2"])
    }

    func testPsyTestList() {
        let sut = PsyTestList(list: ["Test1"])
        XCTAssertEqual(sut.list, ["Test1"])
    }

    func testRegistrationForm() {
        let sut = RegistrationForm(userID: "user@test.com", userPW: "pass123", emailVerified: false)
        XCTAssertEqual(sut.userID, "user@test.com")
        XCTAssertEqual(sut.userPW, "pass123")
        XCTAssertFalse(sut.emailVerified)
    }

    func testSearchText() {
        var sut = SearchText(text: "hello")
        XCTAssertEqual(sut.text, "hello")
        sut.text = "world"
        XCTAssertEqual(sut.text, "world")
    }

    func testSomeLimeTrends() {
        let sut = SomeLimeTrends(list: ["t1", "t2", "t3"])
        XCTAssertEqual(sut.list.count, 3)
    }

    func testUserCurrentComments() {
        let comment = TestFixtures.makeLimeRoomPostComment()
        let sut = UserCurrentComments(list: [comment])
        XCTAssertEqual(sut.list.count, 1)
        XCTAssertEqual(sut.list[0].text, "Test comment")
    }

    func testUserCurrentPosts() {
        let meta = TestFixtures.makeLimeRoomPostMeta()
        let sut = UserCurrentPosts(list: [meta])
        XCTAssertEqual(sut.list.count, 1)
    }

    func testUserProfile() {
        let sut = UserProfile(userName: "User", userID: "u1", userSignedDate: "2024", userPoints: 50, numOfPosts: 10, numOfReceivedVotes: 5, numOfComments: 3, numOfActiveDays: 20)
        XCTAssertEqual(sut.userName, "User")
        XCTAssertEqual(sut.userPoints, 50)
        XCTAssertEqual(sut.numOfActiveDays, 20)
    }

    func testUserStatus() {
        let sut = UserStatus(isLoggedIn: true)
        XCTAssertTrue(sut.isLoggedIn)
    }

    func testUserLimeTypeName() {
        let sut = UserLimeTypeName(name: "SDD")
        XCTAssertEqual(sut.name, "SDD")
    }

    func testHotMyLimeRoomPostList() {
        let sut = HotMyLimeRoomPostList()
        XCTAssertNotNil(sut)
    }

    // MARK: - Phase 3 Entities

    func testSearchResultItem() {
        let postMeta = TestFixtures.makeLimeRoomPostMeta(postID: "p1", title: "Search Hit")
        let sut = SearchResultItem(postMeta: postMeta, boardDisplayName: "board1")
        XCTAssertEqual(sut.postMeta.postID, "p1")
        XCTAssertEqual(sut.postMeta.title, "Search Hit")
        XCTAssertEqual(sut.boardDisplayName, "board1")
    }

    func testSearchResult() {
        let items = [TestFixtures.makeSearchResultItem(postID: "p1", boardName: "board1")]
        let sut = SearchResult(query: "test", items: items, groupedByBoard: ["board1": items])
        XCTAssertEqual(sut.query, "test")
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.groupedByBoard.count, 1)
    }

    func testSearchScope() {
        let title = SearchScope.title
        let content = SearchScope.content
        let both = SearchScope.titleAndContent
        // Just verify they're distinct
        XCTAssertFalse(title == content)
        XCTAssertFalse(content == both)
    }

    func testPsyTestItem() {
        let sut = PsyTestItem(id: "test1", name: "Test", description: "Desc", questionCount: 10, estimatedMinutes: 5, imageName: "img")
        XCTAssertEqual(sut.id, "test1")
        XCTAssertEqual(sut.name, "Test")
        XCTAssertEqual(sut.description, "Desc")
        XCTAssertEqual(sut.questionCount, 10)
        XCTAssertEqual(sut.estimatedMinutes, 5)
        XCTAssertEqual(sut.imageName, "img")
    }
}
