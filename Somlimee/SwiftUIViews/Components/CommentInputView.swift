//
//  CommentInputView.swift
//  Somlimee
//

import SwiftUI

struct CommentInputView: View {
    @Binding var text: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("Write a comment...", text: $text)
                .font(.hanSansNeoRegular(size: 14))
                .textFieldStyle(.roundedBorder)
                .disabled(isSubmitting)

            Button(action: onSubmit) {
                if isSubmitting {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(text.trimmingCharacters(in: .whitespaces).isEmpty ? .somLimeSystemGray : .somLimePrimary)
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

#if DEBUG
#Preview {
    CommentInputView(text: .constant("테스트 댓글"), isSubmitting: false, onSubmit: {})
}
#endif
