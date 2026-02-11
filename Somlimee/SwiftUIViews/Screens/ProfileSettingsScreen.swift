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
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text("Profile Settings")
                    .font(.hanSansNeoBold(size: 18))
                Spacer()
            }
            .padding()

            // Nickname section
            VStack(alignment: .leading, spacing: 8) {
                Text("Nickname")
                    .font(.hanSansNeoBold(size: 14))
                    .foregroundStyle(.secondary)
                TextField("Nickname", text: Binding(
                    get: { vm?.nickname ?? "" },
                    set: { vm?.nickname = $0 }
                ))
                .textFieldStyle(.roundedBorder)

                Button("Save Nickname") {
                    Task { await vm?.updateNickname() }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.somLimePrimary)
                .disabled(vm?.isLoading == true)
            }
            .padding(.horizontal, 40)

            // Email (read-only)
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.hanSansNeoBold(size: 14))
                    .foregroundStyle(.secondary)
                Text(vm?.email ?? "")
                    .font(.hanSansNeoRegular(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 40)

            if let success = vm?.successMessage {
                Text(success)
                    .foregroundStyle(.green)
                    .font(.caption)
            }

            if let error = vm?.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            // Change Password
            NavigationLink(value: Route.changePassword) {
                HStack {
                    Image(systemName: "lock")
                    Text("Change Password")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 40)
            }

            Spacer()

            // Delete Account
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("Delete Account")
                    .font(.hanSansNeoBold(size: 15))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ProfileSettingsViewModel.self) as? ProfileSettingsViewModelImpl
            await vm?.loadProfile()
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            TextField("Email", text: $deleteEmail)
                .autocapitalization(.none)
            SecureField("Password", text: $deletePassword)
            Button("Delete", role: .destructive) {
                Task {
                    let success = await vm?.deleteAccount(email: deleteEmail, password: deletePassword) ?? false
                    if success {
                        onAccountDeleted?()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your credentials to permanently delete your account. This cannot be undone.")
        }
    }
}
