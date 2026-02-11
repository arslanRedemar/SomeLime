//
//  VerifyEmailScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct VerifyEmailScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var vm: VerifyEmailViewModelImpl?
    var onVerified: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                Spacer()
            }
            .padding()

            Spacer()

            Image(systemName: "envelope.badge")
                .font(.system(size: 60))
                .foregroundStyle(Color.somLimePrimary)

            Text("Verify Your Email")
                .font(.hanSansNeoBold(size: 18))

            Text("We sent a verification link to your email. Please check your inbox and verify, then tap \"Check Status\" below.")
                .font(.hanSansNeoRegular(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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

            if vm?.isVerified == true {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Email verified!")
                        .font(.hanSansNeoBold(size: 15))
                        .foregroundStyle(.green)
                }

                Button("Continue to Personality Test") {
                    onVerified?()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.somLimePrimary)
            } else {
                Button("Resend Verification Email") {
                    Task { await vm?.resendVerification() }
                }
                .buttonStyle(.bordered)
                .tint(Color.somLimePrimary)
                .disabled(vm?.isLoading == true)

                Button("Check Status") {
                    Task { await vm?.checkVerificationStatus() }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.somLimePrimary)
                .disabled(vm?.isLoading == true)
            }

            Spacer()
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(VerifyEmailViewModel.self) as? VerifyEmailViewModelImpl
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        VerifyEmailScreen()
    }
    .previewWithContainer()
}
#endif
