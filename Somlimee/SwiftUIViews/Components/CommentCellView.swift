//
//  CommentCellView.swift
//  Somlimee
//

import SwiftUI

struct CommentCellView: View {
    let comment: LimeRoomPostComment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.somLimeSystemGray)

            VStack(alignment: .leading, spacing: 4) {
                // Name + time
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.userName)
                        .font(.hanSansNeoBold(size: 13))
                        .foregroundStyle(Color.somLimeLabel)

                    Text(comment.publishedTime)
                        .font(.hanSansNeoLight(size: 11))
                        .foregroundStyle(.tertiary)
                }

                // Body
                Text(comment.text)
                    .font(.hanSansNeoRegular(size: 14))
                    .foregroundStyle(Color.somLimeLabel)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#if DEBUG
#Preview {
    CommentCellView(comment: PreviewData.sampleComment)
}
#endif
