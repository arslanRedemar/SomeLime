//
//  PsyTestListScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct PsyTestListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var viewModel: PsyTestListViewModel?

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.somLimeLabel)
                }
                Spacer()
                Text("심리 테스트")
                    .font(.hanSansNeoBold(size: 18))
                    .foregroundStyle(Color.somLimeLabel)
                Spacer()
            }
            .padding()

            Divider()

            if viewModel?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else if let items = viewModel?.testItems, !items.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(items, id: \.id) { item in
                            PsyTestCard(item: item)
                        }
                    }
                    .padding()
                }
            } else {
                Spacer()
                Text("등록된 테스트가 없습니다")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            if viewModel == nil {
                viewModel = container.resolve(PsyTestListViewModel.self)
                await viewModel?.loadTests()
            }
        }
    }
}

private struct PsyTestCard: View {
    let item: PsyTestItem

    var body: some View {
        NavigationLink(value: Route.personalityTest) {
            HStack(spacing: 16) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.hanSansNeoBold(size: 15))
                        .foregroundStyle(Color.somLimeLabel)

                    Text(item.description)
                        .font(.hanSansNeoRegular(size: 12))
                        .foregroundStyle(Color.somLimeSecondaryLabel)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        Label("\(item.questionCount)문항", systemImage: "list.bullet")
                        Label("약 \(item.estimatedMinutes)분", systemImage: "clock")
                    }
                    .font(.hanSansNeoRegular(size: 11))
                    .foregroundStyle(Color.somLimeSecondaryLabel)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.somLimeSecondaryLabel)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.somLimeGroupedBackground)
            )
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PsyTestListScreen()
    }
    .previewWithContainer()
}
#endif
