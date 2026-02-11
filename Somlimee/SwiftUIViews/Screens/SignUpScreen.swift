//
//  SignUpScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct SignUpScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var navigateToVerify = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text("Sign Up")
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

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            if let error = errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }

            Button("Create Account") {
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match"
                    return
                }
                Task {
                    do {
                        let auth = container.resolve(AuthRepository.self)!
                        try await auth.createUser(email: email, password: password)
                        try await auth.sendEmailVerification()
                        navigateToVerify = true
                    } catch {
                        errorMessage = "Sign up failed"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.somLimePrimary)

            Spacer()
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToVerify) {
            VerifyEmailScreen()
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SignUpScreen()
    }
    .previewWithContainer()
}
#endif
