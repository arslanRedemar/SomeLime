//
//  PostCellView.swift
//  Somlimee
//

import SwiftUI

struct PostCellView: View {
    let post: LimeRoomPostMeta

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(post.boardPostTap)
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(post.publishedTime.prefix(16)))
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(.secondary)
            }

            Text(post.title)
                .font(.hanSansNeoMedium(size: 14))
                .foregroundStyle(Color.somLimeLabel)
                .lineLimit(2)

            HStack(spacing: 12) {
                Text(post.userName)
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(post.numOfVotes)", systemImage: "arrow.up")
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(.secondary)
                Label("\(post.numOfComments)", systemImage: "bubble.right")
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(.secondary)
                Label("\(post.numOfViews)", systemImage: "eye")
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#if DEBUG
#Preview {
    PostCellView(post: PreviewData.samplePost())
}
#endif
