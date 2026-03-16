//
//  ProfileSettingsScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct ProfileSettingsScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ProfileSettingsViewModelImpl?
    @State private var showDeleteConfirmation = false
    @State private var deleteEmail = ""
    @State private var deletePassword = ""
    var onAccountDeleted: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView {
                VStack(spacing: 16) {
                    // Success / Error messages
                    if let success = vm?.successMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.somLimeSecondary)
                            Text(success)
                                .font(.hanSansNeoMedium(size: 13))
                                .foregroundStyle(Color.somLimeSecondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(Color.somLimeSecondary.opacity(0.1))
                        )
                        .padding(.top, 8)
                    }

                    if let error = vm?.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                            Text(error)
                                .font(.hanSansNeoMedium(size: 13))
                                .foregroundStyle(.red)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(.red.opacity(0.1))
                        )
                        .padding(.top, 8)
                    }

                    // Nickname section
                    settingsCard {
                        cardHeader("닉네임")

                        HStack(spacing: 12) {
                            TextField("닉네임을 입력하세요", text: Binding(
                                get: { vm?.nickname ?? "" },
                                set: { vm?.nickname = $0 }
                            ))
                            .font(.hanSansNeoRegular(size: 15))
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.somLimeGroupedBackground)
                            )

                            Button {
                                Task { await vm?.updateNickname() }
                            } label: {
                                Text("저장")
                                    .font(.hanSansNeoBold(size: 14))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.somLimePrimary)
                                    )
                            }
                            .disabled(vm?.isLoading == true)
                        }
                    }

                    // Email section (read-only)
                    settingsCard {
                        cardHeader("이메일")

                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.somLimeSecondaryLabel)
                            Text(vm?.email ?? "")
                                .font(.hanSansNeoRegular(size: 15))
                                .foregroundStyle(Color.somLimeLabel)
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.somLimeSystemGray)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.somLimeGroupedBackground)
                        )
                    }

                    // Account actions
                    settingsCard {
                        cardHeader("계정 관리")

                        NavigationLink(value: Route.changePassword) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.somLimePrimary)
                                    .frame(width: 20, alignment: .center)
                                Text("비밀번호 변경")
                                    .font(.hanSansNeoMedium(size: 14))
                                    .foregroundStyle(Color.somLimeLabel)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Danger zone
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 15))
                                Text("계정 삭제")
                                    .font(.hanSansNeoMedium(size: 14))
                            }
                            .foregroundStyle(.red.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.red.opacity(0.15), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ProfileSettingsViewModel.self) as? ProfileSettingsViewModelImpl
            await vm?.loadProfile()
        }
        .alert("계정 삭제", isPresented: $showDeleteConfirmation) {
            TextField("이메일", text: $deleteEmail)
                .textInputAutocapitalization(.never)
            SecureField("비밀번호", text: $deletePassword)
            Button("삭제", role: .destructive) {
                Task {
                    let success = await vm?.deleteAccount(email: deleteEmail, password: deletePassword) ?? false
                    if success {
                        onAccountDeleted?()
                    }
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("계정을 영구적으로 삭제하려면 자격 증명을 입력하세요. 이 작업은 되돌릴 수 없습니다.")
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 16) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.somLimeLabel)
                    .frame(width: 36, height: 36)
                    .background(Color.somLimeLightPrimary)
                    .clipShape(Circle())
            }
            .accessibilityLabel("뒤로 가기")

            Spacer()

            Text("프로필 설정")
                .font(.hanSansNeoBold(size: 20))
                .foregroundStyle(Color.somLimeLabel)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.somLimeBackground)
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Settings Card

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.somLimeBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .padding(.horizontal, 16)
    }

    private func cardHeader(_ title: String) -> some View {
        Text(title)
            .font(.hanSansNeoBold(size: 14))
            .foregroundStyle(Color.somLimeSecondaryLabel)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ProfileSettingsScreen()
    }
    .previewWithContainer()
}
#endif
