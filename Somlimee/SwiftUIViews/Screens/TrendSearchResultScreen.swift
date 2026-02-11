//
//  TrendSearchResultScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct TrendSearchResultScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    let keyword: String
    @State private var viewModel: SearchViewModel?

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.somLimeLabel)
                }
                Spacer()
                Text("\"\(keyword)\" 검색 결과")
                    .font(.hanSansNeoBold(size: 16))
                    .foregroundStyle(Color.somLimeLabel)
                Spacer()
            }
            .padding()

            Divider()

            if viewModel?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel?.results.isEmpty == true {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("검색 결과가 없습니다")
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if let grouped = viewModel?.groupedResults {
                            ForEach(Array(grouped.keys.sorted()), id: \.self) { board in
                                if let items = grouped[board], !items.isEmpty {
                                    Section {
                                        ForEach(items, id: \.postMeta.postID) { item in
                                            NavigationLink(value: Route.boardPost(boardName: item.postMeta.boardName, postId: item.postMeta.postID)) {
                                                TrendResultCell(item: item)
                                            }
                                        }
                                    } header: {
                                        HStack {
                                            Text(board)
                                                .font(.hanSansNeoBold(size: 14))
                                                .foregroundStyle(Color.somLimePrimary)
                                            Spacer()
                                            Text("\(items.count)건")
                                                .font(.hanSansNeoRegular(size: 12))
                                                .foregroundStyle(Color.somLimeSecondaryLabel)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color.somLimeGroupedBackground)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            if viewModel == nil {
                viewModel = container.resolve(SearchViewModel.self)
                viewModel?.searchText = keyword
                viewModel?.scope = .titleAndContent
                await viewModel?.search()
            }
        }
    }
}

private struct TrendResultCell: View {
    let item: SearchResultItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.postMeta.title)
                .font(.hanSansNeoMedium(size: 14))
                .foregroundStyle(Color.somLimeLabel)
                .lineLimit(2)

            HStack(spacing: 8) {
                Text(item.postMeta.userName)
                Text(item.postMeta.publishedTime.prefix(10))
                Spacer()
                Label("\(item.postMeta.numOfViews)", systemImage: "eye")
                Label("\(item.postMeta.numOfComments)", systemImage: "bubble.right")
            }
            .font(.hanSansNeoRegular(size: 11))
            .foregroundStyle(Color.somLimeSecondaryLabel)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)

        Divider().padding(.horizontal)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TrendSearchResultScreen(keyword: "라임테스트")
    }
    .previewWithContainer()
}
#endif
