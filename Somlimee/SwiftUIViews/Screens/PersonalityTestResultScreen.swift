//
//  PersonalityTestResultScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct PersonalityTestResultScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var profileVM: ProfileViewModel?

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.somLimeLabel)
                }
                .accessibilityLabel("뒤로 가기")
                Spacer()
                Text("테스트 결과")
                    .font(.hanSansNeoBold(size: 18))
                    .foregroundStyle(Color.somLimeLabel)
                Spacer()
            }
            .padding()

            Divider()

            if profileVM?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else if let result = profileVM?.testResult, let report = profileVM?.testReport {
                ScrollView {
                    VStack(spacing: 24) {
                        // Type icon
                        Image(report.typeImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .padding(.top, 24)

                        // Type name
                        VStack(spacing: 4) {
                            Text(result.typeName)
                                .font(.hanSansNeoBold(size: 28))
                                .foregroundStyle(Color.somLimePrimary)
                            Text(SomeLiMePTTypeDesc.typeDetail[result.typeName] ?? "")
                                .font(.hanSansNeoMedium(size: 16))
                                .foregroundStyle(Color.somLimeLabel)
                        }

                        // 4-axis chart
                        VStack(spacing: 16) {
                            Text("4축 분석")
                                .font(.hanSansNeoBold(size: 16))
                                .foregroundStyle(Color.somLimeLabel)

                            axisBar("활력성 (Strenuousness)", value: result.str, color: .red)
                            axisBar("수용성 (Receptiveness)", value: result.rec, color: .blue)
                            axisBar("조화성 (Harmonization)", value: result.har, color: .green)
                            axisBar("결집성 (Coagulation)", value: result.coa, color: .orange)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.somLimeGroupedBackground)
                        )
                        .padding(.horizontal)

                        // Detailed description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("상세 설명")
                                .font(.hanSansNeoBold(size: 16))
                                .foregroundStyle(Color.somLimeLabel)

                            Text(report.typeDetailedReport)
                                .font(.hanSansNeoRegular(size: 14))
                                .foregroundStyle(Color.somLimeLabel)
                                .lineSpacing(6)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.somLimeGroupedBackground)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            } else {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("테스트 결과가 없습니다")
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundStyle(.secondary)
                    Text("심리 테스트를 먼저 진행해주세요")
                        .font(.hanSansNeoRegular(size: 12))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            if profileVM == nil {
                profileVM = container.resolve(ProfileViewModel.self)
                await profileVM?.loadTestResult()
                await profileVM?.loadTestReport()
            }
        }
    }

    private func axisBar(_ label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.hanSansNeoMedium(size: 13))
                    .foregroundStyle(Color.somLimeLabel)
                Spacer()
                Text("\(value)")
                    .font(.hanSansNeoBold(size: 13))
                    .foregroundStyle(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.somLimeSecondaryLabel.opacity(0.2))
                        .frame(height: 12)

                    let maxVal = 10.0
                    let normalized = min(max(Double(value + 5), 0), maxVal)
                    let width = geo.size.width * (normalized / maxVal)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.7))
                        .frame(width: max(width, 4), height: 12)
                }
            }
            .frame(height: 12)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PersonalityTestResultScreen()
    }
    .previewWithContainer()
}
#endif
