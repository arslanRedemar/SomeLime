//
//  UserCurrentPostsScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct UserCurrentPostsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var vm: UserCurrentPostsViewModelImpl?

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.somLimeLabel)
                }
                Spacer()
                Text("My Posts")
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
            } else if let posts = vm?.posts?.list, !posts.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(posts.enumerated()), id: \.offset) { _, post in
                            NavigationLink(value: Route.boardPost(boardName: post.boardName, postId: post.postID)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(post.boardName)
                                            .font(.hanSansNeoMedium(size: 11))
                                            .foregroundColor(.somLimePrimary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.somLimePrimary.opacity(0.1))
                                            .clipShape(Capsule())
                                        Spacer()
                                        Text(post.publishedTime.prefix(16))
                                            .font(.hanSansNeoLight(size: 11))
                                            .foregroundColor(.somLimeSystemGray)
                                    }

                                    Text(post.title)
                                        .font(.hanSansNeoMedium(size: 15))
                                        .foregroundColor(.somLimeLabel)
                                        .lineLimit(2)

                                    HStack(spacing: 10) {
                                        Label("\(post.numOfVotes)", systemImage: "hand.thumbsup")
                                        Label("\(post.numOfComments)", systemImage: "bubble.right")
                                        Label("\(post.numOfViews)", systemImage: "eye")
                                    }
                                    .font(.hanSansNeoRegular(size: 11))
                                    .foregroundColor(.somLimeSystemGray)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            }
                            Divider().padding(.leading)
                        }
                    }
                }
            } else {
                Spacer()
                if let error = vm?.errorMessage {
                    Text(error)
                        .font(.hanSansNeoRegular(size: 14))
                        .foregroundColor(.red)
                } else {
                    Text("No posts yet")
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
            vm = container.resolve(UserCurrentPostsViewModel.self) as? UserCurrentPostsViewModelImpl
            await vm?.loadPosts()
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        UserCurrentPostsScreen()
    }
    .previewWithContainer()
}
#endif
