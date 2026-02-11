//
//  LimeTrendSection.swift
//  Somlimee
//

import SwiftUI

struct LimeTrendSection: View {
    let trends: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lime Trends")
                .font(.hanSansNeoBold(size: 16))
                .padding(.horizontal)

            FlowLayout(spacing: 8) {
                ForEach(trends, id: \.self) { trend in
                    NavigationLink(value: Route.trendSearchResult(keyword: trend)) {
                        Text(trend)
                            .font(.hanSansNeoRegular(size: 13))
                            .foregroundStyle(Color.somLimeLabel)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.somLimeSystemGray.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LimeTrendSection(trends: PreviewData.trends)
    }
}
#endif
