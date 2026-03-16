//
//  AnswerBarView.swift
//  Somlimee
//

import SwiftUI

struct AnswerBarView: View {
    @Binding var selected: Int

    private let labels = ["SD", "D", "N", "A", "SA"]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<5, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = index
                    }
                } label: {
                    Text(labels[index])
                        .font(.hanSansNeoBold(size: 11))
                        .foregroundStyle(selected == index ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selected == index ? Color.somLimePrimary.gradient : AnyGradient(Gradient(colors: [Color.somLimeLightPrimary])))
                        )
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    AnswerBarView(selected: .constant(2))
        .padding()
}
#endif
