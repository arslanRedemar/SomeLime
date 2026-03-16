//
//  LoginScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct LoginScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel("뒤로 가기")
                Spacer()
            }
            .padding()

            Spacer()

            Image("SomeLimeLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 40)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.hanSansNeoRegular(size: 12))
            }

            Button("Log In") {
                Task {
                    do {
                        let auth = container.resolve(AuthRepository.self)!
                        try await auth.signIn(email: email, password: password)
                        // Ensure Users/{uid} document exists (legacy account migration)
                        let userRepo = container.resolve(UserRepository.self)!
                        if try await userRepo.getUserData() == nil {
                            try await userRepo.createInitialProfile(email: email)
                        }
                        NotificationCenter.default.post(name: .authStateDidChange, object: nil)
                        dismiss()
                    } catch {
                        errorMessage = "Login failed"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.somLimePrimary)

            NavigationLink(value: Route.signUp) {
                Text("Sign Up")
                    .foregroundStyle(Color.somLimePrimary)
            }

            NavigationLink(value: Route.forgotPassword) {
                Text("Forgot Password?")
                    .font(.hanSansNeoRegular(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LoginScreen()
    }
    .previewWithContainer()
}
#endif
