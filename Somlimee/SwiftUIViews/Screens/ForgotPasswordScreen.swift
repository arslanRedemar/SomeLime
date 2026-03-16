//
//  ForgotPasswordScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct ForgotPasswordScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ForgotPasswordViewModelImpl?
    @State private var email = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel("뒤로 가기")
                Spacer()
                Text("Forgot Password")
                    .font(.hanSansNeoBold(size: 18))
                Spacer()
            }
            .padding()

            Spacer()

            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundStyle(Color.somLimePrimary)

            Text("Enter your email to receive a password reset link.")
                .font(.hanSansNeoRegular(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 40)

            if let success = vm?.successMessage {
                Text(success)
                    .foregroundStyle(.green)
                    .font(.hanSansNeoRegular(size: 12))
                    .padding(.horizontal, 40)
            }

            if let error = vm?.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.hanSansNeoRegular(size: 12))
                    .padding(.horizontal, 40)
            }

            Button("Send Reset Link") {
                Task { await vm?.sendPasswordReset(email: email) }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.somLimePrimary)
            .disabled(vm?.isLoading == true || email.isEmpty)

            Spacer()
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ForgotPasswordViewModel.self) as? ForgotPasswordViewModelImpl
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ForgotPasswordScreen()
    }
    .previewWithContainer()
}
#endif
