//
//  BoardPostScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct BoardPostScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var vm: BoardPostViewModelImpl?
    @State private var commentText = ""

    let boardName: String
    let postId: String

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.somLimeLabel)
                }
                .accessibilityLabel("뒤로 가기")
                Text(vm?.meta?.title ?? "Post")
                    .font(.hanSansNeoBold(size: 18))
                    .lineLimit(1)
                Spacer()
                NavigationLink(value: Route.report(boardName: boardName, postId: postId)) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.somLimeSystemGray)
                }
                .accessibilityLabel("신고")
            }
            .padding()
            .background(.ultraThinMaterial)

            if vm?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Post meta
                        if let meta = vm?.meta {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meta.title)
                                    .font(.hanSansNeoBold(size: 20))
                                    .foregroundColor(.somLimeLabel)

                                HStack {
                                    Text(meta.userName)
                                        .font(.hanSansNeoMedium(size: 13))
                                    Spacer()
                                    Text(meta.publishedTime)
                                        .font(.hanSansNeoLight(size: 12))
                                        .foregroundColor(.somLimeSystemGray)
                                }

                                HStack(spacing: 12) {
                                    Button {
                                        Task { await vm?.voteUp(boardName: boardName, postId: postId) }
                                    } label: {
                                        Label("\(meta.numOfVotes)", systemImage: vm?.hasVoted == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                                            .foregroundColor(vm?.hasVoted == true ? .somLimePrimary : .somLimeSystemGray)
                                    }
                                    .disabled(vm?.hasVoted == true)

                                    Label("\(meta.numOfComments)", systemImage: "bubble.right")
                                    Label("\(meta.numOfViews)", systemImage: "eye")
                                }
                                .font(.hanSansNeoRegular(size: 12))
                                .foregroundColor(.somLimeSystemGray)
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }

                        Divider().padding(.horizontal)

                        // Post content
                        if let content = vm?.content {
                            Text(content.paragraph)
                                .font(.hanSansNeoRegular(size: 15))
                                .foregroundColor(.somLimeLabel)
                                .padding(.horizontal)

                            ForEach(content.imageURLs, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Vote up button
                        HStack {
                            Spacer()
                            Button {
                                Task { await vm?.voteUp(boardName: boardName, postId: postId) }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: vm?.hasVoted == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    Text("추천")
                                        .font(.hanSansNeoMedium(size: 14))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(vm?.hasVoted == true ? Color.somLimePrimary.opacity(0.15) : Color.somLimeSystemGray.opacity(0.15))
                                .foregroundColor(vm?.hasVoted == true ? .somLimePrimary : .somLimeLabel)
                                .clipShape(Capsule())
                            }
                            .disabled(vm?.hasVoted == true)
                            Spacer()
                        }
                        .padding(.vertical, 8)

                        Divider().padding(.horizontal)

                        // Comments header
                        Text("댓글 (\(vm?.comments.count ?? 0))")
                            .font(.hanSansNeoBold(size: 15))
                            .padding(.horizontal)

                        // Comment list
                        if let comments = vm?.comments, !comments.isEmpty {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(comments.enumerated()), id: \.offset) { _, comment in
                                    CommentCellView(comment: comment)
                                    Divider().padding(.leading)
                                }
                            }
                        } else {
                            Text("댓글이 없습니다")
                                .font(.hanSansNeoRegular(size: 14))
                                .foregroundColor(.somLimeSystemGray)
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                        }
                    }
                }
                .refreshable {
                    await vm?.loadPost(boardName: boardName, postId: postId)
                    await vm?.loadComments(boardName: boardName, postId: postId)
                }

                // Comment input
                CommentInputView(
                    text: $commentText,
                    isSubmitting: vm?.isSubmittingComment ?? false,
                    onSubmit: {
                        let text = commentText.trimmingCharacters(in: .whitespaces)
                        guard !text.isEmpty else { return }
                        let mockComment = LimeRoomPostComment(
                            userName: "Me",
                            userID: "local_user",
                            postID: postId,
                            target: postId,
                            publishedTime: ISO8601DateFormatter().string(from: Date()),
                            isRevised: false,
                            text: text,
                            boardName: boardName
                        )
                        vm?.comments.insert(mockComment, at: 0)
                        commentText = ""
                        Task {
                            await vm?.submitComment(boardName: boardName, postId: postId, text: text)
                        }
                    }
                )
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(BoardPostViewModel.self) as? BoardPostViewModelImpl
            await vm?.loadPost(boardName: boardName, postId: postId)
            await vm?.loadComments(boardName: boardName, postId: postId)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        BoardPostScreen(boardName: "SDR", postId: "post_0")
    }
    .previewWithContainer()
}
#endif
