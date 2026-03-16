//
//  CommentInputView.swift
//  Somlimee
//

import SwiftUI

struct CommentInputView: View {
    @Binding var text: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty && !isSubmitting
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField("댓글을 입력하세요...", text: $text)
                .font(.hanSansNeoRegular(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.somLimeLightPrimary)
                )
                .disabled(isSubmitting)

            Button(action: onSubmit) {
                Group {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 15, weight: .medium))
                    }
                }
                .foregroundStyle(canSubmit ? Color.white : Color.somLimeSystemGray)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(canSubmit ? Color.somLimePrimary.gradient : AnyGradient(Gradient(colors: [Color.somLimeSystemGray.opacity(0.3)])))
                )
            }
            .disabled(!canSubmit)
            .accessibilityLabel("댓글 전송")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.somLimeBackground)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

#if DEBUG
#Preview {
    CommentInputView(text: .constant("테스트 댓글"), isSubmitting: false, onSubmit: {})
}
#endif
