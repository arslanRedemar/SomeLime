//
//  ReportViewModel.swift
//  Somlimee
//

import Foundation

protocol ReportViewModel {
    var selectedReason: ReportReason { get set }
    var detailText: String { get set }
    var isSubmitting: Bool { get }
    var isSubmitted: Bool { get }
    var errorMessage: String? { get }
    func submitReport(boardName: String, postId: String) async
}

@Observable
final class ReportViewModelImpl: ReportViewModel {
    var selectedReason: ReportReason = .spam
    var detailText: String = ""
    var isSubmitting = false
    var isSubmitted = false
    var errorMessage: String?

    private let reportUC: UCReportContent

    init(reportUC: UCReportContent) {
        self.reportUC = reportUC
    }

    func submitReport(boardName: String, postId: String) async {
        Log.vm.info("ReportViewModel.submitReport: board=\(boardName) postId=\(postId) reason=\(self.selectedReason.rawValue)")
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let form = ReportForm(
            targetType: "post",
            targetId: postId,
            boardName: boardName,
            reason: selectedReason,
            detail: detailText
        )

        let result = await reportUC.report(form: form)
        switch result {
        case .success:
            Log.vm.info("ReportViewModel.submitReport: success")
            isSubmitted = true
        case .failure(let error):
            Log.vm.error("ReportViewModel.submitReport: failed — \(error)")
            errorMessage = error.localizedDescription
        }
    }
}
