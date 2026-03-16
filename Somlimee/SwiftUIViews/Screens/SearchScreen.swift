//
//  SearchScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct SearchScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var viewModel: SearchViewModel?

    private let scopeLabels = ["제목", "내용", "제목+내용"]

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.somLimeLabel)
                }
                .accessibilityLabel("뒤로 가기")
                TextField("검색어를 입력하세요", text: searchTextBinding)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await viewModel?.search() } }
                Button {
                    Task { await viewModel?.search() }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.somLimePrimary)
                }
                .accessibilityLabel("검색")
            }
            .padding()

            // Scope selector
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    let scope: SearchScope = [.title, .content, .titleAndContent][index]
                    Button {
                        viewModel?.scope = scope
                    } label: {
                        Text(scopeLabels[index])
                            .font(.hanSansNeoMedium(size: 13))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(currentScope == scope ? Color.somLimePrimary : Color.somLimeSecondaryLabel)
                            .overlay(alignment: .bottom) {
                                if currentScope == scope {
                                    Rectangle()
                                        .fill(Color.somLimePrimary)
                                        .frame(height: 2)
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)

            Divider()

            // Results
            if viewModel?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel?.errorMessage {
                Spacer()
                Text(error).foregroundStyle(.secondary)
                Spacer()
            } else if viewModel?.hasSearched == true {
                if viewModel?.results.isEmpty == true {
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
                    searchResultsList
                }
            } else {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("검색어를 입력해주세요")
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            if viewModel == nil {
                viewModel = container.resolve(SearchViewModel.self)
            }
        }
    }

    private var currentScope: SearchScope {
        viewModel?.scope ?? .title
    }

    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let grouped = viewModel?.groupedResults, !grouped.isEmpty {
                    ForEach(Array(grouped.keys.sorted()), id: \.self) { board in
                        if let items = grouped[board], !items.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(board)
                                    .font(.hanSansNeoBold(size: 14))
                                    .foregroundStyle(Color.somLimePrimary)
                                    .padding(.horizontal)
                                    .padding(.top, 12)

                                ForEach(items, id: \.postMeta.postID) { item in
                                    NavigationLink(value: Route.boardPost(boardName: item.postMeta.boardName, postId: item.postMeta.postID)) {
                                        SearchResultCell(item: item)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel?.search()
        }
    }
}

private struct SearchResultCell: View {
    let item: SearchResultItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.postMeta.title)
                .font(.hanSansNeoMedium(size: 14))
                .foregroundStyle(Color.somLimeLabel)
                .lineLimit(2)

            HStack(spacing: 8) {
                Text(item.postMeta.userName)
                    .font(.hanSansNeoRegular(size: 11))
                Text(item.postMeta.publishedTime.prefix(10))
                    .font(.hanSansNeoRegular(size: 11))
                Spacer()
                Label("\(item.postMeta.numOfViews)", systemImage: "eye")
                    .font(.hanSansNeoRegular(size: 11))
                Label("\(item.postMeta.numOfComments)", systemImage: "bubble.right")
                    .font(.hanSansNeoRegular(size: 11))
            }
            .foregroundStyle(Color.somLimeSecondaryLabel)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.somLimeBackground)

        Divider().padding(.horizontal)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SearchScreen()
    }
    .previewWithContainer()
}
#endif
