@testable import Somlimee
import Foundation

enum TestFixtures {

    // MARK: - Profile Data

    static func makeProfileData(
        userName: String = "TestUser",
        personalityType: String = "SDD"
    ) -> ProfileData {
        ProfileData(
            userName: userName,
            profileImageURL: nil,
            totalUps: 10,
            signUpDate: "2024-01-01",
            numOfPosts: 5,
            receivedUps: 3,
            points: 100,
            daysOfActive: 30,
            badges: ["badge1"],
            personalityTestResult: makePersonalityTestResult(type: personalityType),
            personalityType: personalityType
        )
    }

    static func makeProfileDict(
        userName: String = "TestUser",
        personalityType: String = "SDD"
    ) -> [String: Any] {
        [
            "UserName": userName,
            "TotalUps": 10,
            "SignUpDate": "2024-01-01",
            "NumOfPosts": 5,
            "ReceivedUps": 3,
            "Points": 100,
            "DaysOfActive": 30,
            "badges": ["badge1"],
            "PersonalityTestResult": [10, 20, 30, 40],
            "PersonalityType": personalityType
        ]
    }

    // MARK: - PersonalityTestResult

    static func makePersonalityTestResult(type: String = "SDD") -> PersonalityTestResultData {
        PersonalityTestResultData(
            Strenuousness: 10,
            Receptiveness: 20,
            Harmonization: 30,
            Coagulation: 40,
            type: type
        )
    }

    // MARK: - Board Info

    static func makeBoardInfoData(
        boardName: String = "TestBoard",
        description: String = "Test Description"
    ) -> BoardInfoData {
        BoardInfoData(
            boardName: boardName,
            boardOwnerID: "owner1",
            tapList: ["General", "Hot"],
            boardLevel: 1,
            boardDescription: description,
            boardHotKeyword: ["keyword1"]
        )
    }

    static func makeBoardInfoDict(description: String = "Test Description") -> [String: Any] {
        [
            "BoardOwnerId": "owner1",
            "BoardTapList": ["General", "Hot"],
            "BoardLevel": 1,
            "BoardDescription": description,
            "BoardHotKeywords": ["keyword1"]
        ]
    }

    // MARK: - Board Post Meta

    static func makeBoardPostMetaData(
        boardID: String = "board1",
        postID: String = "post1",
        title: String = "Test Post"
    ) -> BoardPostMetaData {
        BoardPostMetaData(
            boardID: boardID,
            postID: postID,
            publishedTime: "2024-01-01",
            postType: .text,
            postTitle: title,
            boardTap: "General",
            userID: "user1",
            userName: "TestUser",
            numberOfViews: 10,
            numberOfVoteUps: 2,
            numberOfComments: 1
        )
    }

    static func makeBoardPostMetaDict(
        postID: String = "post1",
        title: String = "Test Post"
    ) -> [String: Any] {
        [
            "PostId": postID,
            "PublishedTime": "2024-01-01",
            "PostType": "text",
            "PostTitle": title,
            "BoardTap": "General",
            "UserId": "user1",
            "UserName": "TestUser",
            "Views": 10,
            "VoteUps": 2,
            "CommentsNumber": 1
        ]
    }

    // MARK: - Board Post Content

    static func makeBoardPostContentData(
        title: String = "Test Post",
        paragraph: String = "Test paragraph"
    ) -> BoardPostContentData {
        BoardPostContentData(
            boardPostTap: "General",
            boardPostUserId: "user1",
            boardPostTitle: title,
            boardPostParagraph: paragraph,
            boardPostImageURLs: [],
            boardPostComments: []
        )
    }

    // MARK: - Board Post Comment

    static func makeBoardPostCommentData(
        text: String = "Test comment"
    ) -> BoardPostCommentData {
        BoardPostCommentData(
            userName: "TestUser",
            userID: "user1",
            postID: "post1",
            target: "",
            publishedTime: "2024-01-01",
            isRevised: "No",
            text: text
        )
    }

    static func makeBoardPostCommentDict(text: String = "Test comment") -> [String: Any] {
        [
            "UserName": "TestUser",
            "UserId": "user1",
            "PostId": "post1",
            "Target": "",
            "PublishedTime": "2024-01-01",
            "IsRevised": "No",
            "Text": text
        ]
    }

    // MARK: - LimeRoom Entities

    static func makeLimeRoomMeta(
        name: String = "TestRoom",
        description: String = "Test Description"
    ) -> LimeRoomMeta {
        LimeRoomMeta(
            limeRoomName: name,
            limeRoomDescription: description,
            limeRoomTabs: ["General", "Hot"],
            limeRoomImageName: name
        )
    }

    static func makeLimeRoomPostMeta(
        postID: String = "post1",
        title: String = "Test Post"
    ) -> LimeRoomPostMeta {
        LimeRoomPostMeta(
            userID: "user1",
            userName: "TestUser",
            title: title,
            views: 10,
            publishedTime: "2024-01-01",
            numOfVotes: 2,
            numOfComments: 1,
            numOfViews: 10,
            postID: postID,
            boardPostTap: "General",
            boardName: "board1"
        )
    }

    static func makeLimeRoomPostContent(
        paragraph: String = "Test paragraph"
    ) -> LimeRoomPostContent {
        LimeRoomPostContent(
            paragraph: paragraph,
            imageURLs: [],
            imgLocation: [],
            comments: []
        )
    }

    static func makeLimeRoomPostComment(
        text: String = "Test comment"
    ) -> LimeRoomPostComment {
        LimeRoomPostComment(
            userName: "TestUser",
            userID: "user1",
            postID: "post1",
            target: "",
            publishedTime: "2024-01-01",
            isRevised: false,
            text: text,
            boardName: "SDR"
        )
    }

    // MARK: - Search

    static func makeSearchResultItem(
        postID: String = "post1",
        title: String = "Test Post",
        boardName: String = "board1"
    ) -> SearchResultItem {
        SearchResultItem(
            postMeta: LimeRoomPostMeta(
                userID: "user1",
                userName: "TestUser",
                title: title,
                views: 10,
                publishedTime: "2024-01-01",
                numOfVotes: 2,
                numOfComments: 1,
                numOfViews: 10,
                postID: postID,
                boardPostTap: "General",
                boardName: boardName
            ),
            boardDisplayName: boardName
        )
    }

    static func makeSearchResult(
        query: String = "test",
        items: [SearchResultItem]? = nil
    ) -> SearchResult {
        let resultItems = items ?? [makeSearchResultItem()]
        var grouped: [String: [SearchResultItem]] = [:]
        for item in resultItems {
            grouped[item.boardDisplayName, default: []].append(item)
        }
        return SearchResult(query: query, items: resultItems, groupedByBoard: grouped)
    }

    // MARK: - Personality Test

    static func makePersonalityTestQuestions() -> PersonalityTestQuestions {
        PersonalityTestQuestions(
            questions: [
                "질문 1",
                "질문 2",
                "질문 3",
            ],
            category: [.Fire, .Water, .Air],
            answers: [.Neutral]
        )
    }

    static func makePsyTestItem(
        id: String = "somlime_personality",
        name: String = "SomLiMe 성격 테스트"
    ) -> PsyTestItem {
        PsyTestItem(
            id: id,
            name: name,
            description: "테스트 설명",
            questionCount: 5,
            estimatedMinutes: 3,
            imageName: "NDR"
        )
    }

    // MARK: - Category / Trends

    static func makeCategoryData() -> CategoryData {
        CategoryData(list: ["Cat1", "Cat2", "Cat3"])
    }

    static func makeLimeTrendsData() -> LimeTrendsData {
        LimeTrendsData(trendsList: ["trend1", "trend2"])
    }

    static func makeLimeTrendsDict() -> [String: Any] {
        ["List": ["trend1", "trend2"]]
    }
}
