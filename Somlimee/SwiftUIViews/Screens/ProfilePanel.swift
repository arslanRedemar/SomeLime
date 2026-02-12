//
//  ProfilePanel.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct ProfilePanel: View {
    @Environment(\.diContainer) private var container
    @State private var vm: ProfileViewModelImpl?
    var onNavigate: (Route) -> Void
    var onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let error = vm?.errorMessage {
                Text(error)
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            // Profile header
            profileHeader
                .padding(.bottom, 16)

            // Test result (compact)
            if let result = vm?.testResult {
                compactTestResult(result)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }

            Divider()
                .padding(.horizontal, 16)

            // Menu items (logged-in only)
            if vm?.userProfile != nil {
                VStack(spacing: 0) {
                    menuRow(icon: "pencil.and.list.clipboard", title: "내 게시글") {
                        onNavigate(.userCurrentPosts)
                    }
                    menuRow(icon: "text.bubble", title: "내 댓글") {
                        onNavigate(.userCurrentComments)
                    }
                    menuRow(icon: "brain.head.profile", title: "성격 테스트 결과") {
                        onNavigate(.personalityTestResult)
                    }
                    menuRow(icon: "gearshape", title: "프로필 설정") {
                        onNavigate(.profileSettings)
                    }
                }
                .padding(.vertical, 8)
            }

            Spacer()

            // Sign out
            Divider()
                .padding(.horizontal, 16)

            if vm?.userProfile != nil {
                Button(action: {
                    vm?.signOut()
                    onSignOut()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 15))
                        Text("로그아웃")
                            .font(.hanSansNeoMedium(size: 14))
                    }
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
            }
        }
        .padding(.top, 60)
        .background(
            Color.somLimeBackground
                .shadow(color: .black.opacity(0.15), radius: 10, x: -4, y: 0)
        )
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ProfileViewModel.self) as? ProfileViewModelImpl
            await vm?.loadProfile()
            await vm?.loadTestResult()
        }
    }

    // MARK: - Profile Header

    @ViewBuilder
    private var profileHeader: some View {
        if let profile = vm?.userProfile {
            VStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.somLimePrimary.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "person.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color.somLimePrimary)
                }

                // Name
                Text(profile.userName)
                    .font(.hanSansNeoBold(size: 18))
                    .foregroundStyle(Color.somLimeLabel)

                // Stats row
                HStack(spacing: 0) {
                    statItem(value: profile.numOfPosts, label: "게시글")
                    statDivider
                    statItem(value: profile.numOfReceivedVotes, label: "추천")
                    statDivider
                    statItem(value: profile.userPoints, label: "포인트")
                    statDivider
                    statItem(value: profile.numOfActiveDays, label: "활동일")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.somLimeGroupedBackground)
                )
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
        } else {
            // Not logged in
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.somLimeSystemGray.opacity(0.3))
                        .frame(width: 72, height: 72)
                    Image(systemName: "person.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color.somLimeSecondaryLabel)
                }

                Text("로그인이 필요합니다")
                    .font(.hanSansNeoMedium(size: 15))
                    .foregroundStyle(Color.somLimeSecondaryLabel)

                Button {
                    onNavigate(.login)
                } label: {
                    Text("로그인")
                        .font(.hanSansNeoBold(size: 14))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.somLimePrimary)
                        )
                }
                .padding(.horizontal, 40)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Compact Test Result

    private func compactTestResult(_ result: LimeTestResult) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(result.typeName)
                    .font(.hanSansNeoBold(size: 14))
                    .foregroundStyle(Color.somLimePrimary)
                Spacer()
                Text(result.typeDesc)
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(Color.somLimeSecondaryLabel)
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                axisPill("S", value: result.str, color: .red)
                axisPill("R", value: result.rec, color: .blue)
                axisPill("H", value: result.har, color: .green)
                axisPill("C", value: result.coa, color: .orange)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.somLimeGroupedBackground)
        )
    }

    private func axisPill(_ label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.hanSansNeoBold(size: 10))
                .foregroundStyle(color)
            Text("\(value)")
                .font(.hanSansNeoRegular(size: 10))
                .foregroundStyle(Color.somLimeLabel)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - Menu Row

    private func menuRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.somLimePrimary)
                    .frame(width: 24, alignment: .center)

                Text(title)
                    .font(.hanSansNeoMedium(size: 14))
                    .foregroundStyle(Color.somLimeLabel)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.somLimeSecondaryLabel)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.hanSansNeoBold(size: 14))
                .foregroundStyle(Color.somLimeLabel)
            Text(label)
                .font(.hanSansNeoRegular(size: 10))
                .foregroundStyle(Color.somLimeSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.somLimeSecondaryLabel.opacity(0.3))
            .frame(width: 1, height: 24)
    }
}

#if DEBUG
#Preview {
    ProfilePanel(onNavigate: { _ in }, onSignOut: {})
        .frame(width: 300)
        .previewWithContainer()
}
#endif
