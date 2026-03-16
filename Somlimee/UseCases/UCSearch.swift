//
//  UCSearch.swift
//  Somlimee
//

import Foundation

protocol UCSearch {
    func execute(query: String, boardName: String?, scope: SearchScope) async -> Result<SearchResult, Error>
    func getAvailableBoards() async -> Result<[String], Error>
}

class UCSearchImpl: UCSearch {
    private let searchRepository: SearchRepository

    init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    func getAvailableBoards() async -> Result<[String], Error> {
        Log.useCase.debug("UCSearch.getAvailableBoards: start")
        do {
            let boards = try await searchRepository.getAvailableBoards()
            Log.useCase.debug("UCSearch.getAvailableBoards: success — \(boards.count) boards")
            return .success(boards)
        } catch {
            Log.useCase.error("UCSearch.getAvailableBoards: failed — \(error)")
            return .failure(UCSearchFailures.searchFailed)
        }
    }

    func execute(query: String, boardName: String?, scope: SearchScope) async -> Result<SearchResult, Error> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            Log.useCase.debug("UCSearch.execute: rejected empty query")
            return .failure(UCSearchFailures.emptyQuery)
        }

        Log.useCase.debug("UCSearch.execute: query=\(trimmed) board=\(boardName ?? "all") scope=\(String(describing: scope))")
        do {
            let items = try await searchRepository.searchPosts(
                query: trimmed,
                boardName: boardName,
                scope: scope,
                counts: 50
            )

            var grouped: [String: [SearchResultItem]] = [:]
            for item in items {
                grouped[item.boardDisplayName, default: []].append(item)
            }

            let result = SearchResult(query: trimmed, items: items, groupedByBoard: grouped)
            Log.useCase.debug("UCSearch.execute: success — \(items.count) results in \(grouped.count) boards")
            return .success(result)
        } catch {
            Log.useCase.error("UCSearch.execute: failed — \(error)")
            return .failure(UCSearchFailures.searchFailed)
        }
    }
}
