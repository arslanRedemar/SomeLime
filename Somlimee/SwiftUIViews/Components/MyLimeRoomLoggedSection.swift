//
//  MyLimeRoomLoggedSection.swift
//  Somlimee
//

import SwiftUI

struct MyLimeRoomLoggedSection: View {
    let typeName: String
    let posts: [LimeRoomPostMeta]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !typeName.isEmpty {
                    Image(typeName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                VStack(alignment: .leading) {
                    Text("My Lime Room")
                        .font(.hanSansNeoBold(size: 16))
                    Text(typeName)
                        .font(.hanSansNeoRegular(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            ForEach(Array(posts.prefix(4).enumerated()), id: \.offset) { _, post in
                PostCellView(post: post)
                Divider().padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview {
    MyLimeRoomLoggedSection(
        typeName: "SDR",
        posts: PreviewData.samplePosts
    )
}
#endif
