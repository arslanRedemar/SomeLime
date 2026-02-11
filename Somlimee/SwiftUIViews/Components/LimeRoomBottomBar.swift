//
//  LimeRoomBottomBar.swift
//  Somlimee
//

import SwiftUI

struct LimeRoomBottomBar: View {
    let currentPage: Int
    var onPageChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                if currentPage > 0 { onPageChange(currentPage - 1) }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(currentPage > 0 ? Color.somLimeLabel : .secondary)
            }
            .disabled(currentPage == 0)

            Text("Page \(currentPage + 1)")
                .font(.hanSansNeoMedium(size: 14))

            Button {
                onPageChange(currentPage + 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.somLimeLabel)
            }
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

#if DEBUG
#Preview {
    LimeRoomBottomBar(currentPage: 0, onPageChange: { _ in })
}
#endif
