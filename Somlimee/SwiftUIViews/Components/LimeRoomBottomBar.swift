//
//  LimeRoomBottomBar.swift
//  Somlimee
//

import SwiftUI

struct LimeRoomBottomBar: View {
    let currentPage: Int
    var onPageChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button {
                if currentPage > 0 { onPageChange(currentPage - 1) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(currentPage > 0 ? Color.somLimePrimary : Color.somLimeSystemGray)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(currentPage > 0 ? Color.somLimeLightPrimary : Color.somLimeSystemGray.opacity(0.3))
                    )
            }
            .disabled(currentPage == 0)
            .accessibilityLabel("이전 페이지")

            Text("\(currentPage + 1)")
                .font(.hanSansNeoBold(size: 15))
                .foregroundStyle(Color.somLimeLabel)
                .frame(minWidth: 28)

            Button {
                onPageChange(currentPage + 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.somLimePrimary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.somLimeLightPrimary)
                    )
            }
            .accessibilityLabel("다음 페이지")
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.somLimeBackground)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

#if DEBUG
#Preview {
    LimeRoomBottomBar(currentPage: 0, onPageChange: { _ in })
}
#endif
