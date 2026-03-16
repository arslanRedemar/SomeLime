//
//  PreviewHelpers.swift
//  Somlimee
//
//  Preview sample data and container setup for SwiftUI Previews.
//

#if DEBUG
import SwiftUI
import Swinject

enum PreviewData {

    // MARK: - User

    static let userProfile = UserProfile(
        userName: "LimeUser",
        userID: "uid_preview_001",
        userSignedDate: "2024-01-15",
        userPoints: 1280,
        numOfPosts: 42,
        numOfReceivedVotes: 156,
        numOfComments: 87,
        numOfActiveDays: 93
    )

    // MARK: - Personality Test

    static let testResult = LimeTestResult(
        str: 3, rec: -1, har: 2, coa: 0,
        typeName: "SDR",
        typeDesc: "활력성 우세 표준형"
    )

    static let testReport = LimeTestReport(
        typeName: "SDR",
        typeDetailedReport: "활력성 우세 표준형은 다른 세가지 특성보다 활력성이 우월한 유형입니다.",
        typeImageName: "SDR"
    )

    static let psyTestItem = PsyTestItem(
        id: "somlime_personality",
        name: "SomLiMe 성격 테스트",
        description: "4가지 축을 기반으로 당신의 성격 유형을 분석합니다.",
        questionCount: 5,
        estimatedMinutes: 3,
        imageName: "NDR"
    )

    // MARK: - Posts

    static func samplePost(index: Int = 0) -> LimeRoomPostMeta {
        LimeRoomPostMeta(
            userID: "uid_\(index)",
            userName: "User\(index)",
            title: "게시글 제목 \(index) - 테스트 데이터입니다",
            views: 120 + index * 30,
            publishedTime: "2024-03-0\(index + 1)",
            numOfVotes: 10 + index * 3,
            numOfComments: 5 + index,
            numOfViews: 120 + index * 30,
            postID: "post_\(index)",
            boardPostTap: "일반",
            boardName: "SDR"
        )
    }

    static let samplePosts: [LimeRoomPostMeta] = (0..<5).map { samplePost(index: $0) }

    // MARK: - Trends

    static let trends: [String] = ["라임테스트", "성격유형", "MBTI", "심리분석", "활력성"]

    // MARK: - Comments

    static let sampleComment = LimeRoomPostComment(
        userName: "LimeUser2",
        userID: "uid_002",
        postID: "post_0",
        target: "post_0",
        publishedTime: "2024-03-01 12:30",
        isRevised: false,
        text: "정말 좋은 글이네요! 공감합니다.",
        boardName: "SDR"
    )

    static let sampleComments: [LimeRoomPostComment] = [
        sampleComment,
        LimeRoomPostComment(
            userName: "TestUser3",
            userID: "uid_003",
            postID: "post_0",
            target: "post_0",
            publishedTime: "2024-03-01 14:15",
            isRevised: false,
            text: "저도 같은 생각이에요.",
            boardName: "SDR"
        )
    ]

    // MARK: - Lime Rooms

    static let limeRooms: [String] = ["SDR", "CDR", "HDR", "NDR", "RDR"]

    // MARK: - DI Container (for Screen previews)

    static var previewContainer: Container {
        let container = Container()
        DIContainer.setupContainer(container)
        return container
    }
}

// MARK: - View Extension for Preview Container

extension View {
    func previewWithContainer() -> some View {
        self.environment(\.diContainer, PreviewData.previewContainer)
    }
}
#endif
