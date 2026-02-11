//
//  PersonalityTestScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct PersonalityTestScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var viewModel: PersonalityTestViewModel?

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.somLimeLabel)
                }
                Spacer()
                Text("성격 테스트")
                    .font(.hanSansNeoBold(size: 18))
                    .foregroundStyle(Color.somLimeLabel)
                Spacer()
            }
            .padding()

            if viewModel?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel?.errorMessage {
                Spacer()
                Text(error).foregroundStyle(.secondary)
                Spacer()
            } else if viewModel?.isCompleted == true {
                testCompletedView
            } else if let vm = viewModel, !vm.questions.isEmpty {
                testProgressView(vm)
            } else {
                Spacer()
                Text("테스트를 불러오는 중...")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            if viewModel == nil {
                viewModel = container.resolve(PersonalityTestViewModel.self)
                await viewModel?.loadQuestions()
            }
        }
    }

    private func testProgressView(_ vm: PersonalityTestViewModel) -> some View {
        VStack(spacing: 24) {
            // Progress bar
            VStack(spacing: 4) {
                ProgressView(value: vm.progress)
                    .tint(Color.somLimePrimary)
                Text("\(vm.currentIndex + 1) / \(vm.questions.count)")
                    .font(.hanSansNeoRegular(size: 12))
                    .foregroundStyle(Color.somLimeSecondaryLabel)
            }
            .padding(.horizontal)

            Spacer()

            // Question
            Text(vm.currentQuestion)
                .font(.hanSansNeoBold(size: 20))
                .foregroundStyle(Color.somLimeLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Answer buttons
            VStack(spacing: 12) {
                answerButton("매우 그렇다", answer: .StronglyAgree)
                answerButton("그렇다", answer: .Agree)
                answerButton("보통이다", answer: .Neutral)
                answerButton("아니다", answer: .Disagree)
                answerButton("매우 아니다", answer: .StronglyDisagree)
            }
            .padding(.horizontal, 32)

            // Back button
            if vm.currentIndex > 0 {
                Button {
                    viewModel?.goBack()
                } label: {
                    Text("이전 질문")
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundStyle(Color.somLimeSecondaryLabel)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
    }

    private func answerButton(_ label: String, answer: Answer) -> some View {
        Button {
            viewModel?.selectAnswer(answer)
        } label: {
            Text(label)
                .font(.hanSansNeoMedium(size: 16))
                .foregroundStyle(Color.somLimeLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.somLimeGroupedBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.somLimePrimary.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var testCompletedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.somLimePrimary)

            Text("테스트 완료!")
                .font(.hanSansNeoBold(size: 24))
                .foregroundStyle(Color.somLimeLabel)

            if let result = viewModel?.result {
                let typeName = SomeLiMePTTypeDesc.typeDetail[result.type] ?? result.type
                Text(typeName)
                    .font(.hanSansNeoMedium(size: 18))
                    .foregroundStyle(Color.somLimePrimary)

                resultBars(result)
            }

            Spacer()

            Button {
                Task { await viewModel?.finishTest() }
                dismiss()
            } label: {
                Text("결과 저장하기")
                    .font(.hanSansNeoBold(size: 16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.somLimePrimary)
                    )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private func resultBars(_ result: PersonalityTestResultData) -> some View {
        VStack(spacing: 12) {
            resultBar("활력성", value: result.Strenuousness, color: .red)
            resultBar("수용성", value: result.Receptiveness, color: .blue)
            resultBar("조화성", value: result.Harmonization, color: .green)
            resultBar("결집성", value: result.Coagulation, color: .orange)
        }
        .padding(.horizontal, 32)
    }

    private func resultBar(_ label: String, value: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.hanSansNeoMedium(size: 13))
                .foregroundStyle(Color.somLimeLabel)
                .frame(width: 50, alignment: .leading)

            GeometryReader { geo in
                let maxVal = 10.0
                let normalized = min(max(Double(value + 5), 0), maxVal)
                let width = geo.size.width * (normalized / maxVal)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.7))
                    .frame(width: max(width, 4), height: 20)
            }
            .frame(height: 20)

            Text("\(value)")
                .font(.hanSansNeoRegular(size: 12))
                .foregroundStyle(Color.somLimeSecondaryLabel)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PersonalityTestScreen()
    }
    .previewWithContainer()
}
#endif
