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
    @State private var isLoading = false
    @State private var navigateToVerify = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
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
                Text("회원가입")
                    .font(.hanSansNeoBold(size: 18))
                    .foregroundStyle(Color.somLimeLabel)
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding()

            Spacer()

            TextField("이메일", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 40)

            SecureField("비밀번호", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            SecureField("비밀번호 확인", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.hanSansNeoRegular(size: 13))
            }

            Button {
                guard password == confirmPassword else {
                    errorMessage = "비밀번호가 일치하지 않습니다"
                    return
                }
                guard !email.isEmpty else {
                    errorMessage = "이메일을 입력해주세요"
                    return
                }
                guard password.count >= 6 else {
                    errorMessage = "비밀번호는 6자 이상이어야 합니다"
                    return
                }
                isLoading = true
                errorMessage = nil
                Task {
                    do {
                        let auth = container.resolve(AuthRepository.self)!
                        let userRepo = container.resolve(UserRepository.self)!
                        try await auth.createUser(email: email, password: password)
                        try await userRepo.createInitialProfile(email: email)
                        try await auth.sendEmailVerification()
                        isLoading = false
                        navigateToVerify = true
                    } catch {
                        isLoading = false
                        errorMessage = "회원가입에 실패했습니다"
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("계정 만들기")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.somLimePrimary)
            .disabled(isLoading)

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
