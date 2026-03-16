//
//  MyLimeRoomLoggedSection.swift
//  Somlimee
//

import SwiftUI

struct MyLimeRoomLoggedSection: View {
    let typeName: String
    let posts: [LimeRoomPostMeta]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section title
            Text("나의 라임방")
                .font(.hanSansNeoBold(size: 18))
                .foregroundStyle(Color.somLimeLabel)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            HStack(alignment: .top, spacing: 14) {
                // Left: Lime room image + type name
                NavigationLink(value: Route.limeRoom(boardName: typeName)) {
                    VStack(spacing: 8) {
                        Image(typeName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.somLimePrimary.opacity(0.3), lineWidth: 1)
                            )

                        Text(typeName)
                            .font(.hanSansNeoBold(size: 13))
                            .foregroundStyle(Color.somLimePrimary)
                    }
                }
                .buttonStyle(.plain)

                // Right: Hot posts preview
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("핫 게시물")
                            .font(.hanSansNeoBold(size: 14))
                            .foregroundStyle(Color.somLimeLabel)
                        Spacer()
                        NavigationLink(value: Route.limeRoom(boardName: typeName)) {
                            Text("더보기")
                                .font(.hanSansNeoMedium(size: 12))
                                .foregroundStyle(Color.somLimePrimary)
                        }
                    }
                    .padding(.bottom, 8)

                    // Post list (compact)
                    if posts.isEmpty {
                        Text("아직 게시물이 없습니다")
                            .font(.hanSansNeoRegular(size: 12))
                            .foregroundStyle(.tertiary)
                            .padding(.vertical, 12)
                    } else {
                        ForEach(Array(posts.prefix(5).enumerated()), id: \.offset) { index, post in
                            hotPostRow(post)
                            if index < min(posts.count, 5) - 1 {
                                Divider()
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.somLimeBackground)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .padding(.horizontal, 16)
    }

    private func hotPostRow(_ post: LimeRoomPostMeta) -> some View {
        NavigationLink(value: Route.boardPost(boardName: post.boardName, postId: post.postID)) {
            HStack(spacing: 6) {
                Text(post.title)
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(Color.somLimeLabel)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if post.numOfComments > 0 {
                    Text("[\(post.numOfComments)]")
                        .font(.hanSansNeoMedium(size: 11))
                        .foregroundStyle(Color.somLimePrimary)
                }

                Text(RelativeTimeFormatter.string(from: post.publishedTime))
                    .font(.hanSansNeoLight(size: 11))
                    .foregroundStyle(.tertiary)
                    .fixedSize()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MyLimeRoomLoggedSection(
            typeName: "SDR",
            posts: PreviewData.samplePosts
        )
    }
}
#endif
