//
//  UserCurrentCommentsScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct UserCurrentCommentsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var vm: UserCurrentCommentsViewModelImpl?

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.somLimeLabel)
                }
                .accessibilityLabel("뒤로 가기")
                Spacer()
                Text("My Comments")
                    .font(.hanSansNeoBold(size: 18))
                Spacer()
                Image(systemName: "chevron.left").hidden()
            }
            .padding()
            .background(.ultraThinMaterial)

            if vm?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else if let comments = vm?.comments?.list, !comments.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(comments.enumerated()), id: \.offset) { _, comment in
                            NavigationLink(value: Route.boardPost(boardName: comment.boardName, postId: comment.postID)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(comment.userName)
                                            .font(.hanSansNeoMedium(size: 13))
                                            .foregroundColor(.somLimeLabel)
                                        Spacer()
                                        Text(comment.publishedTime.prefix(16))
                                            .font(.hanSansNeoLight(size: 11))
                                            .foregroundColor(.somLimeSystemGray)
                                    }

                                    Text(comment.text)
                                        .font(.hanSansNeoRegular(size: 14))
                                        .foregroundColor(.somLimeLabel)
                                        .lineLimit(3)

                                    if !comment.postID.isEmpty {
                                        Text("Post: \(comment.postID)")
                                            .font(.hanSansNeoLight(size: 11))
                                            .foregroundColor(.somLimeSystemGray)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading)
                        }
                    }
                }
                .refreshable {
                    await vm?.loadComments()
                }
            } else {
                Spacer()
                if let error = vm?.errorMessage {
                    Text(error)
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundColor(.red)
                } else {
                    Text("No comments yet")
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundColor(.somLimeSystemGray)
                }
                Spacer()
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(UserCurrentCommentsViewModel.self) as? UserCurrentCommentsViewModelImpl
            await vm?.loadComments()
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        UserCurrentCommentsScreen()
    }
    .previewWithContainer()
}
#endif
