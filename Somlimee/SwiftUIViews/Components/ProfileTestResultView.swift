//
//  ProfileTestResultView.swift
//  Somlimee
//

import SwiftUI

struct ProfileTestResultView: View {
    let result: LimeTestResult

    var body: some View {
        VStack(spacing: 8) {
            Text(result.typeName)
                .font(.hanSansNeoBold(size: 16))
            Text(result.typeDesc)
                .font(.hanSansNeoRegular(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            PersonalityBarChart(
                str: result.str,
                rec: result.rec,
                har: result.har,
                coa: result.coa
            )
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    ProfileTestResultView(result: PreviewData.testResult)
}
#endif
