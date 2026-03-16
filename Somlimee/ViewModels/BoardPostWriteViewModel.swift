//
//  BoardPostWriteViewModel.swift
//  Somlimee
//

import Foundation

protocol BoardPostWriteViewModel {
    var isSubmitting: Bool { get }
    var isSubmitted: Bool { get }
    var errorMessage: String? { get }
    var selectedImageData: [Data] { get set }
    func submitPost(boardName: String, title: String, paragraph: String) async
    func removeImage(at index: Int)
}

@Observable
final class BoardPostWriteViewModelImpl: BoardPostWriteViewModel {
    var isSubmitting = false
    var isSubmitted = false
    var errorMessage: String?
    var selectedImageData: [Data] = []

    private let writePost: UCWritePost
    private let authRepo: AuthRepository
    private let postRepo: PostRepository

    init(writePost: UCWritePost, authRepo: AuthRepository, postRepo: PostRepository) {
        self.writePost = writePost
        self.authRepo = authRepo
        self.postRepo = postRepo
    }

    func removeImage(at index: Int) {
        guard index >= 0 && index < selectedImageData.count else { return }
        Log.vm.debug("BoardPostWriteViewModel.removeImage: index=\(index)")
        selectedImageData.remove(at: index)
    }

    func submitPost(boardName: String, title: String, paragraph: String) async {
        Log.vm.info("BoardPostWriteViewModel.submitPost: board=\(boardName) title=\(title)")
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let userId = authRepo.currentUserID ?? ""

        // Upload images if any
        var imageURLs: [String] = []
        for (index, imageData) in selectedImageData.enumerated() {
            let path = "posts/\(userId)/\(UUID().uuidString)_\(index).jpg"
            do {
                let url = try await postRepo.uploadImage(data: imageData, path: path)
                imageURLs.append(url)
                Log.vm.debug("BoardPostWriteViewModel.submitPost: uploaded image \(index + 1)")
            } catch {
                Log.vm.error("BoardPostWriteViewModel.submitPost: image upload failed — \(error)")
                errorMessage = "Failed to upload image \(index + 1)"
                return
            }
        }

        let content = LimeRoomPostContent(paragraph: paragraph, imageURLs: imageURLs, imgLocation: [], comments: [])
        let meta = LimeRoomPostMeta(userID: userId, userName: "", title: title, views: 0, publishedTime: "", numOfVotes: 0, numOfComments: 0, numOfViews: 0, postID: "", boardPostTap: "", boardName: boardName)

        let result = await writePost.writePost(boardName: boardName, postContents: content, postMeta: meta)
        switch result {
        case .success:
            Log.vm.info("BoardPostWriteViewModel.submitPost: success")
            isSubmitted = true
        case .failure(let error):
            Log.vm.error("BoardPostWriteViewModel.submitPost: failed — \(error)")
            errorMessage = error.localizedDescription
        }
    }
}
