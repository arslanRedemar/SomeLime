//
//  LimeTrendSection.swift
//  Somlimee
//

import SwiftUI

struct LimeTrendSection: View {
    let trends: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.somLimeSecondary)
                Text("라임 트렌드")
                    .font(.hanSansNeoBold(size: 17))
                    .foregroundStyle(Color.somLimeLabel)
            }
            .padding(.horizontal, 16)

            FlowLayout(spacing: 8) {
                ForEach(trends, id: \.self) { trend in
                    NavigationLink(value: Route.trendSearchResult(keyword: trend)) {
                        Text(trend)
                            .font(.hanSansNeoMedium(size: 13))
                            .foregroundStyle(Color.somLimeDarkPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.somLimeLightPrimary)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.somLimePrimary.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
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
