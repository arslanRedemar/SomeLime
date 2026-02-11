//
//  ProfileCardView.swift
//  Somlimee
//

import SwiftUI

struct ProfileCardView: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.somLimePrimary)

            Text(profile.userName)
                .font(.hanSansNeoBold(size: 18))

            HStack(spacing: 20) {
                statItem(label: "Posts", value: profile.numOfPosts)
                statItem(label: "Votes", value: profile.numOfReceivedVotes)
                statItem(label: "Points", value: profile.userPoints)
                statItem(label: "Days", value: profile.numOfActiveDays)
            }
        }
        .padding()
    }

    private func statItem(label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.hanSansNeoBold(size: 14))
            Text(label)
                .font(.hanSansNeoRegular(size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    ProfileCardView(profile: PreviewData.userProfile)
}
#endif
