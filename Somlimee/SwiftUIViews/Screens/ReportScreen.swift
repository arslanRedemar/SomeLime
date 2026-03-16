//
//  ReportScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct ReportScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var vm: ReportViewModelImpl?
    @State private var showSuccess = false

    let boardName: String
    let postId: String

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.somLimeLabel)
                }
                .accessibilityLabel("닫기")
                Spacer()
                Text("Report")
                    .font(.hanSansNeoBold(size: 18))
                Spacer()
                // Placeholder for symmetry
                Image(systemName: "xmark").hidden()
            }
            .padding()
            .background(.ultraThinMaterial)

            if vm?.isSubmitting == true {
                Spacer()
                ProgressView("Submitting...")
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Select reason")
                            .font(.hanSansNeoBold(size: 16))
                            .foregroundColor(.somLimeLabel)
                            .padding(.horizontal)
                            .padding(.top, 16)

                        VStack(spacing: 0) {
                            ForEach(ReportReason.allCases, id: \.rawValue) { reason in
                                Button {
                                    vm?.selectedReason = reason
                                } label: {
                                    HStack {
                                        Image(systemName: vm?.selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(vm?.selectedReason == reason ? .somLimePrimary : .somLimeSystemGray)
                                        Text(reason.displayName)
                                            .font(.hanSansNeoRegular(size: 15))
                                            .foregroundColor(.somLimeLabel)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                if reason != ReportReason.allCases.last {
                                    Divider().padding(.leading)
                                }
                            }
                        }
                        .background(Color.somLimeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)

                        Text("Additional details")
                            .font(.hanSansNeoBold(size: 16))
                            .foregroundColor(.somLimeLabel)
                            .padding(.horizontal)

                        TextEditor(text: Binding(
                            get: { vm?.detailText ?? "" },
                            set: { vm?.detailText = $0 }
                        ))
                        .font(.hanSansNeoRegular(size: 14))
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.somLimeSystemGray, lineWidth: 1)
                        )
                        .padding(.horizontal)

                        if let error = vm?.errorMessage {
                            Text(error)
                                .font(.hanSansNeoRegular(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        Button {
                            Task {
                                await vm?.submitReport(boardName: boardName, postId: postId)
                            }
                        } label: {
                            Text("Submit Report")
                                .font(.hanSansNeoBold(size: 16))
                                .foregroundColor(.somLimeLabelLight)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.somLimePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(Color.somLimeGroupedBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ReportViewModel.self) as? ReportViewModelImpl
        }
        .onChange(of: vm?.isSubmitted) { _, submitted in
            if submitted == true {
                showSuccess = true
            }
        }
        .alert("신고 접수 완료", isPresented: $showSuccess) {
            Button("확인") { dismiss() }
        } message: {
            Text("신고가 접수되었습니다. 감사합니다.")
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReportScreen(boardName: "SDR", postId: "post_0")
    }
    .previewWithContainer()
}
#endif
