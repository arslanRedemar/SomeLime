//
//  ChangePasswordScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct ChangePasswordScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ChangePasswordViewModelImpl?
    @State private var email = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text("Change Password")
                    .font(.hanSansNeoBold(size: 18))
                Spacer()
            }
            .padding()

            Spacer()

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 40)

            SecureField("Current Password", text: $currentPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            SecureField("Confirm New Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
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

            Button("Update Password") {
                Task {
                    let success = await vm?.changePassword(
                        email: email,
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                        confirmPassword: confirmPassword
                    ) ?? false
                    if success {
                        try? await Task.sleep(for: .seconds(1))
                        dismiss()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.somLimePrimary)
            .disabled(vm?.isLoading == true)

            Spacer()
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ChangePasswordViewModel.self) as? ChangePasswordViewModelImpl
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ChangePasswordScreen()
    }
    .previewWithContainer()
}
#endif
