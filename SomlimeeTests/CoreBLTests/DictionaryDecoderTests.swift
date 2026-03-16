@testable import Somlimee
import XCTest

final class DictionaryDecoderTests: XCTestCase {

    func testDecodeSimpleStruct() throws {
        let dict: [String: Any] = ["list": ["A", "B"]]
        let result = try DictionaryDecoder.decode(CategoryData.self, from: dict)
        XCTAssertEqual(result.list, ["A", "B"])
    }

    func testDecodeWithCodingKeys() throws {
        let dict: [String: Any] = [
            "UserName": "Alice",
            "UserId": "u1",
            "PostId": "p1",
            "Target": "",
            "PublishedTime": "2024-01-01",
            "IsRevised": "No",
            "Text": "Hello"
        ]
        let result = try DictionaryDecoder.decode(BoardPostCommentData.self, from: dict)
        XCTAssertEqual(result.userName, "Alice")
        XCTAssertEqual(result.userID, "u1")
        XCTAssertEqual(result.text, "Hello")
    }

    func testDecodeNestedObjects() throws {
        let dict = TestFixtures.makeProfileDict()
        let result = try DictionaryDecoder.decode(ProfileData.self, from: dict)
        XCTAssertEqual(result.personalityTestResult.Strenuousness, 10)
        XCTAssertEqual(result.personalityTestResult.Receptiveness, 20)
    }

    func testDecodeEmptyDictFailsForRequiredFields() {
        let dict: [String: Any] = [:]
        XCTAssertThrowsError(try DictionaryDecoder.decode(CategoryData.self, from: dict))
    }

    func testDecodeTypeMismatchThrows() {
        let dict: [String: Any] = ["list": 42]
        XCTAssertThrowsError(try DictionaryDecoder.decode(CategoryData.self, from: dict))
    }

    func testDecodeBoardInfoWithDefaults() throws {
        let dict = TestFixtures.makeBoardInfoDict()
        let result = try DictionaryDecoder.decode(BoardInfoData.self, from: dict)
        XCTAssertEqual(result.boardName, "")
        XCTAssertEqual(result.boardOwnerID, "owner1")
    }

    func testDecodeBoardPostMetaWithMissingFields() throws {
        let dict: [String: Any] = ["PostTitle": "Only Title"]
        let result = try DictionaryDecoder.decode(BoardPostMetaData.self, from: dict)
        XCTAssertEqual(result.postTitle, "Only Title")
        XCTAssertEqual(result.numberOfViews, 0)
        XCTAssertEqual(result.publishedTime, "NaN")
    }
}
