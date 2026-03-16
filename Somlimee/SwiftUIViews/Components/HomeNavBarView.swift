//
//  HomeNavBarView.swift
//  Somlimee
//

import SwiftUI

struct HomeNavBarView: View {
    var onMenuTap: () -> Void
    var onNotificationTap: (() -> Void)?
    var onProfileTap: () -> Void
    var hasUnreadNotifications = false

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.somLimeLabel)
                    .frame(width: 36, height: 36)
                    .background(Color.somLimeLightPrimary)
                    .clipShape(Circle())
            }
            .accessibilityLabel("메뉴")

            Spacer()

            Image("SomeLimeLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 26)

            Spacer()

            if let onNotificationTap {
                Button(action: onNotificationTap) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.somLimeLabel)
                        .frame(width: 36, height: 36)
                        .background(Color.somLimeLightPrimary)
                        .clipShape(Circle())
                        .overlay(alignment: .topTrailing) {
                            if hasUnreadNotifications {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 2, y: -2)
                            }
                        }
                }
                .accessibilityLabel(hasUnreadNotifications ? "알림, 읽지 않은 알림 있음" : "알림")
            }

            Button(action: onProfileTap) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.somLimePrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.somLimeLightPrimary)
                    .clipShape(Circle())
            }
            .accessibilityLabel("프로필")
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
    HomeNavBarView(onMenuTap: {}, onNotificationTap: {}, onProfileTap: {}, hasUnreadNotifications: true)
}
#endif
