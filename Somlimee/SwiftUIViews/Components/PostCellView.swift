//
//  PostCellView.swift
//  Somlimee
//

import SwiftUI

struct PostCellView: View {
    let post: LimeRoomPostMeta

    var body: some View {
        NavigationLink(value: Route.boardPost(boardName: post.boardName, postId: post.postID)) {
            VStack(alignment: .leading, spacing: 10) {
                // 상단: 카테고리 태그 + 시간
                HStack(spacing: 6) {
                    Text(post.boardPostTap)
                        .font(.hanSansNeoMedium(size: 11))
                        .foregroundStyle(Color.somLimePrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.somLimeLightPrimary)
                        .clipShape(Capsule())

                    Spacer()

                    Text(String(post.publishedTime.prefix(16)))
                        .font(.hanSansNeoLight(size: 11))
                        .foregroundStyle(.tertiary)
                }

                // 제목
                Text(post.title)
                    .font(.hanSansNeoMedium(size: 15))
                    .foregroundStyle(Color.somLimeLabel)
                    .lineLimit(2)

                // 하단: 작성자 + 통계
                HStack(spacing: 0) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.quaternary)
                    Text(post.userName)
                        .font(.hanSansNeoRegular(size: 12))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)

                    Spacer()

                    HStack(spacing: 14) {
                        statItem(icon: "arrow.up", count: post.numOfVotes)
                        statItem(icon: "bubble.right", count: post.numOfComments)
                        statItem(icon: "eye", count: post.numOfViews)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.somLimeBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func statItem(icon: String, count: Int) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text("\(count)")
                .font(.hanSansNeoRegular(size: 11))
        }
        .foregroundStyle(.tertiary)
    }
}

#if DEBUG
#Preview {
    PostCellView(post: PreviewData.samplePost())
}
#endif
