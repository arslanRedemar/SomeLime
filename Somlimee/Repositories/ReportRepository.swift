//
//  ReportRepository.swift
//  Somlimee
//

import Foundation

protocol ReportRepository {
    func submitReport(boardName: String, postId: String, reason: String, detail: String) async throws
}

class ReportRepositoryImpl: ReportRepository {
    private let dataSource: DataSource

    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    func submitReport(boardName: String, postId: String, reason: String, detail: String) async throws {
        Log.repo.info("[ReportRepositoryImpl.submitReport] Submitting report for board=\(boardName) postId=\(postId) reason=\(reason)")
        do {
            try await dataSource.createReport(boardName: boardName, postId: postId, reason: reason, detail: detail)
            Log.repo.info("[ReportRepositoryImpl.submitReport] Successfully submitted report for postId=\(postId)")
        } catch {
            Log.repo.error("[ReportRepositoryImpl.submitReport] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            throw error
        }
    }
}
