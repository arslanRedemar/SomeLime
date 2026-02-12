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
        do {
            let boards = try await searchRepository.getAvailableBoards()
            return .success(boards)
        } catch {
            return .failure(UCSearchFailures.searchFailed)
        }
    }

    func execute(query: String, boardName: String?, scope: SearchScope) async -> Result<SearchResult, Error> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure(UCSearchFailures.emptyQuery)
        }

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
            return .success(result)
        } catch {
            return .failure(UCSearchFailures.searchFailed)
        }
    }
}
