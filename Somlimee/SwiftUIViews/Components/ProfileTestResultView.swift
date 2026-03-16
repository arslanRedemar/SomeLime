//
//  ProfileTestResultView.swift
//  Somlimee
//

import SwiftUI

struct ProfileTestResultView: View {
    let result: LimeTestResult

    var body: some View {
        VStack(spacing: 12) {
            // Type badge
            Text(result.typeName)
                .font(.hanSansNeoBold(size: 18))
                .foregroundStyle(Color.somLimePrimary)

            Text(result.typeDesc)
                .font(.hanSansNeoRegular(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            PersonalityBarChart(
                str: result.str,
                rec: result.rec,
                har: result.har,
                coa: result.coa
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.somLimeBackground)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
        )
    }
}

#if DEBUG
#Preview {
    ProfileTestResultView(result: PreviewData.testResult)
        .padding()
}
#endif
