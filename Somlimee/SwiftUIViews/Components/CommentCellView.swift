//
//  CommentCellView.swift
//  Somlimee
//

import SwiftUI

struct CommentCellView: View {
    let comment: LimeRoomPostComment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.userName)
                    .font(.hanSansNeoBold(size: 13))
                    .foregroundColor(.somLimeLabel)
                Spacer()
                Text(comment.publishedTime)
                    .font(.hanSansNeoLight(size: 11))
                    .foregroundColor(.somLimeSystemGray)
            }
            Text(comment.text)
                .font(.hanSansNeoRegular(size: 14))
                .foregroundColor(.somLimeLabel)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview {
    CommentCellView(comment: PreviewData.sampleComment)
}
#endif
