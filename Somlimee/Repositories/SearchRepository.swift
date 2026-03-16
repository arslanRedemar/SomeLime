//
//  SearchRepository.swift
//  Somlimee
//

import Foundation

protocol SearchRepository {
    func searchPosts(query: String, boardName: String?, scope: SearchScope, counts: Int) async throws -> [SearchResultItem]
    func getAvailableBoards() async throws -> [String]
}

class SearchRepositoryImpl: SearchRepository {
    private let dataSource: DataSource

    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    func getAvailableBoards() async throws -> [String] {
        Log.repo.debug("[SearchRepositoryImpl.getAvailableBoards] Fetching available boards")
        do {
            guard let list = try await dataSource.getBoardListData()?["list"] as? [String] else {
                Log.repo.debug("[SearchRepositoryImpl.getAvailableBoards] No boards found")
                return []
            }
            Log.repo.debug("[SearchRepositoryImpl.getAvailableBoards] Successfully fetched \(list.count) boards")
            return list
        } catch {
            Log.repo.error("[SearchRepositoryImpl.getAvailableBoards] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func searchPosts(query: String, boardName: String?, scope: SearchScope, counts: Int) async throws -> [SearchResultItem] {
        Log.repo.debug("[SearchRepositoryImpl.searchPosts] Searching query=\(query) boardName=\(boardName ?? "all") counts=\(counts)")
        do {
            let boards: [String]
            if let boardName = boardName {
                boards = [boardName]
            } else {
                boards = try await getAvailableBoards()
            }

            var results: [SearchResultItem] = []
            let lowercasedQuery = query.lowercased()

            for board in boards {
                guard let metaList = try await dataSource.getBoardPostMetaList(
                    boardName: board, startTime: nil, counts: counts
                ) else { continue }

                for data in metaList {
                    let meta = try DictionaryDecoder.decode(BoardPostMetaData.self, from: data)
                    let matches: Bool
                    switch scope {
                    case .title:
                        matches = meta.postTitle.lowercased().contains(lowercasedQuery)
                    case .content:
                        let contentText = await fetchPostContentText(boardName: board, postId: meta.postID)
                        matches = contentText.lowercased().contains(lowercasedQuery)
                    case .titleAndContent:
                        if meta.postTitle.lowercased().contains(lowercasedQuery) {
                            matches = true
                        } else {
                            let contentText = await fetchPostContentText(boardName: board, postId: meta.postID)
                            matches = contentText.lowercased().contains(lowercasedQuery)
                        }
                    }

                    if matches {
                        let postMeta = LimeRoomPostMeta(
                            userID: meta.userID,
                            userName: meta.userName,
                            title: meta.postTitle,
                            views: meta.numberOfViews,
                            publishedTime: meta.publishedTime,
                            numOfVotes: meta.numberOfVoteUps,
                            numOfComments: meta.numberOfComments,
                            numOfViews: meta.numberOfViews,
                            postID: meta.postID,
                            boardPostTap: meta.boardTap,
                            boardName: board
                        )
                        results.append(SearchResultItem(postMeta: postMeta, boardDisplayName: board))
                    }
                }
            }
            Log.repo.debug("[SearchRepositoryImpl.searchPosts] Search completed with \(results.count) results across \(boards.count) boards")
            return results
        } catch {
            Log.repo.error("[SearchRepositoryImpl.searchPosts] Failed for query=\(query) — \(error.localizedDescription)")
            throw error
        }
    }

    private func fetchPostContentText(boardName: String, postId: String) async -> String {
        do {
            guard let contentData = try await dataSource.getBoardPostContent(boardName: boardName, postId: postId) else {
                return ""
            }
            return (contentData.first?["Text"] as? String) ?? ""
        } catch {
            Log.repo.error("[SearchRepositoryImpl.fetchPostContentText] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            return ""
        }
    }
}
