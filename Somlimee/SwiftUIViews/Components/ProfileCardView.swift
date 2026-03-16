//
//  ProfileCardView.swift
//  Somlimee
//

import SwiftUI

struct ProfileCardView: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.somLimePrimary.gradient)

            // Name
            Text(profile.userName)
                .font(.hanSansNeoBold(size: 20))
                .foregroundStyle(Color.somLimeLabel)

            // Stats row
            HStack(spacing: 0) {
                profileStat(label: "게시글", value: profile.numOfPosts)
                profileDivider()
                profileStat(label: "추천", value: profile.numOfReceivedVotes)
                profileDivider()
                profileStat(label: "포인트", value: profile.userPoints)
                profileDivider()
                profileStat(label: "활동일", value: profile.numOfActiveDays)
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.somLimeLightPrimary)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.somLimeBackground)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
        )
    }

    private func profileStat(label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.hanSansNeoBold(size: 16))
                .foregroundStyle(Color.somLimeDarkPrimary)
            Text(label)
                .font(.hanSansNeoRegular(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func profileDivider() -> some View {
        Rectangle()
            .fill(Color.somLimeSystemGray.opacity(0.5))
            .frame(width: 1, height: 28)
    }
}

#if DEBUG
#Preview {
    ProfileCardView(profile: PreviewData.userProfile)
        .padding()
}
#endif
