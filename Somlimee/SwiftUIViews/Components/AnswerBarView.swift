//
//  AnswerBarView.swift
//  Somlimee
//

import SwiftUI

struct AnswerBarView: View {
    @Binding var selected: Int

    private let labels = ["SD", "D", "N", "A", "SA"]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3)) { selected = index }
                } label: {
                    Circle()
                        .fill(selected == index ? Color.somLimePrimary : Color.somLimeSystemGray)
                        .frame(width: selected == index ? 36 : 28, height: selected == index ? 36 : 28)
                        .overlay(
                            Text(labels[index])
                                .font(.hanSansNeoBold(size: 10))
                                .foregroundStyle(.white)
                        )
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    AnswerBarView(selected: .constant(2))
}
#endif
