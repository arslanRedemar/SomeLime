//
//  PersonalityBarChart.swift
//  Somlimee
//

import SwiftUI

struct PersonalityBarChart: View {
    let str: Int
    let rec: Int
    let har: Int
    let coa: Int

    private var maxVal: Int { max(max(str, rec), max(har, coa)) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            barItem(label: "STR", value: str)
            barItem(label: "REC", value: rec)
            barItem(label: "HAR", value: har)
            barItem(label: "COA", value: coa)
        }
        .padding()
    }

    private func barItem(label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.hanSansNeoRegular(size: 11))
                .foregroundStyle(.secondary)
            GeometryReader { geo in
                let ratio = maxVal > 0 ? CGFloat(value) / CGFloat(maxVal) : 0
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.somLimePrimary)
                    .frame(height: geo.size.height * ratio)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 100)
            Text(label)
                .font(.hanSansNeoBold(size: 10))
                .foregroundStyle(Color.somLimeLabel)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview {
    PersonalityBarChart(str: 3, rec: -1, har: 2, coa: 0)
}
#endif
