//
//  UCReportContent.swift
//  Somlimee
//

import Foundation

protocol UCReportContent {
    func report(form: ReportForm) async -> Result<Void, Error>
}

class UCReportContentImpl: UCReportContent {
    private let reportRepository: ReportRepository

    init(reportRepository: ReportRepository) {
        self.reportRepository = reportRepository
    }

    func report(form: ReportForm) async -> Result<Void, Error> {
        Log.useCase.info("UCReportContent.report: board=\(form.boardName) targetId=\(form.targetId) reason=\(form.reason.rawValue)")
        do {
            try await reportRepository.submitReport(
                boardName: form.boardName,
                postId: form.targetId,
                reason: form.reason.rawValue,
                detail: form.detail
            )
            Log.useCase.info("UCReportContent.report: success")
            return .success(())
        } catch {
            Log.useCase.error("UCReportContent.report: failed — \(error)")
            return .failure(error)
        }
    }
}
