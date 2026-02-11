//
//  LimeTestSection.swift
//  Somlimee
//

import SwiftUI

struct LimeTestSection: View {
    let testList: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lime Tests")
                .font(.hanSansNeoBold(size: 16))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(testList, id: \.self) { test in
                        NavigationLink(value: Route.personalityTest) {
                            VStack {
                                Image(test)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(SomeLiMePTTypeDesc.typeDetail[test] ?? test)
                                    .font(.hanSansNeoRegular(size: 11))
                                    .foregroundStyle(Color.somLimeLabel)
                                    .lineLimit(2)
                                    .frame(width: 100)
                            }
                        }
                    }
                }
                .padding(.horizontal)
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
