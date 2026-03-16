//
//  TabSelectorView.swift
//  Somlimee
//

import SwiftUI

struct TabSelectorView: View {
    let tabs: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedIndex = index }
                } label: {
                    Text(tab)
                        .font(.hanSansNeoMedium(size: 13))
                        .foregroundStyle(selectedIndex == index ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedIndex == index ? Color.somLimePrimary : Color.somLimeLightPrimary)
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview {
    TabSelectorView(tabs: ["MY라임방", "오늘의 라임", "라임 테스트"], selectedIndex: .constant(0))
}
#endif
