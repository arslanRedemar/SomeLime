//
//  TabSelectorView.swift
//  Somlimee
//

import SwiftUI

struct TabSelectorView: View {
    let tabs: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation { selectedIndex = index }
                } label: {
                    VStack(spacing: 4) {
                        Text(tab)
                            .font(.hanSansNeoMedium(size: 14))
                            .foregroundStyle(selectedIndex == index ? Color.somLimePrimary : .secondary)
                            .padding(.vertical, 8)
                        Rectangle()
                            .fill(selectedIndex == index ? Color.somLimePrimary : .clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color.somLimeBackground)
    }
}

#if DEBUG
#Preview {
    TabSelectorView(tabs: ["MY라임방", "오늘의 라임", "라임 테스트"], selectedIndex: .constant(0))
}
#endif
