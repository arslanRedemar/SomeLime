//
//  LimeRoomNavBarView.swift
//  Somlimee
//

import SwiftUI

struct LimeRoomNavBarView: View {
    let title: String
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.somLimeLabel)
                    .frame(width: 32, height: 32)
                    .background(Color.somLimeLightPrimary)
                    .clipShape(Circle())
            }
            .accessibilityLabel("뒤로 가기")

            Text(title)
                .font(.hanSansNeoBold(size: 18))
                .foregroundStyle(Color.somLimeLabel)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.somLimeBackground)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

#if DEBUG
#Preview {
    LimeRoomNavBarView(title: "SDR", onBack: {})
}
#endif
