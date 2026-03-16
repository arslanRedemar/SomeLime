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

    private var maxVal: Int { max(max(abs(str), abs(rec)), max(abs(har), abs(coa))) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            barItem(label: "STR", value: str)
            barItem(label: "REC", value: rec)
            barItem(label: "HAR", value: har)
            barItem(label: "COA", value: coa)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.somLimeLightPrimary)
        )
    }

    private func barItem(label: String, value: Int) -> some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.hanSansNeoBold(size: 12))
                .foregroundStyle(Color.somLimePrimary)

            GeometryReader { geo in
                let ratio = maxVal > 0 ? CGFloat(abs(value)) / CGFloat(maxVal) : 0
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.somLimePrimary.gradient)
                    .frame(height: geo.size.height * ratio)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 100)

            Text(label)
                .font(.hanSansNeoBold(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview {
    PersonalityBarChart(str: 3, rec: -1, har: 2, coa: 0)
        .padding()
}
#endif
