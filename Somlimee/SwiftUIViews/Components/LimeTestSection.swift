//
//  LimeTestSection.swift
//  Somlimee
//

import SwiftUI

struct LimeTestSection: View {
    let testList: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("라임 테스트")
                .font(.hanSansNeoBold(size: 17))
                .foregroundStyle(Color.somLimeLabel)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(testList, id: \.self) { test in
                        NavigationLink(value: Route.personalityTest) {
                            VStack(spacing: 0) {
                                Image(test)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipped()

                                Text(SomeLiMePTTypeDesc.typeDetail[test] ?? test)
                                    .font(.hanSansNeoMedium(size: 12))
                                    .foregroundStyle(Color.somLimeLabel)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 8)
                            }
                            .background(Color.somLimeBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.somLimeSystemGray.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LimeTestSection(testList: ["SDR", "CDR", "NDR"])
    }
}
#endif
