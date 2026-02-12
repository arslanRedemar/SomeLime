//
//  SearchViewModel.swift
//  Somlimee
//

import Foundation

protocol SearchViewModel {
    var searchText: String { get set }
    var scope: SearchScope { get set }
    var selectedBoard: String? { get set }
    var availableBoards: [String] { get }
    var results: [SearchResultItem] { get }
    var groupedResults: [String: [SearchResultItem]] { get }
    var isLoading: Bool { get }
    var hasSearched: Bool { get }
    var errorMessage: String? { get }
    func search() async
    func loadBoards() async
}

@Observable
final class SearchViewModelImpl: SearchViewModel {
    var searchText = ""
    var scope: SearchScope = .title
    var selectedBoard: String?
    var availableBoards: [String] = []
    var results: [SearchResultItem] = []
    var groupedResults: [String: [SearchResultItem]] = [:]
    var isLoading = false
    var hasSearched = false
    var errorMessage: String?

    private let searchUC: UCSearch

    init(searchUC: UCSearch) {
        self.searchUC = searchUC
    }

    func loadBoards() async {
        let result = await searchUC.getAvailableBoards()
        if case .success(let boards) = result {
            availableBoards = boards.sorted()
        }
    }

    func search() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let result = await searchUC.execute(
            query: trimmed,
            boardName: selectedBoard,
            scope: scope
        )

        hasSearched = true
        switch result {
        case .success(let searchResult):
            results = searchResult.items
            groupedResults = searchResult.groupedByBoard
        case .failure:
            results = []
            groupedResults = [:]
            errorMessage = "검색에 실패했습니다."
        }
    }
}
