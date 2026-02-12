//
//  RemoteDataSourceService.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


final class FirebaseDataSource: RemoteDataSource {

    var database: Firestore?

    init(){
        database = Firestore.firestore()
    }

    private func parseBoardName(_ boardName: String) -> String {
        String(boardName.filter({ $0 != "/" }))
    }

    private func convertTimestamps(_ data: [String: Any]) -> [String: Any] {
        var result = data
        for (key, value) in result {
            if let ts = value as? Timestamp {
                result[key] = ts.dateValue().description
            }
        }
        return result
    }

    func getLimeTrendsData() async throws -> [String : Any]? {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        let docRef = db.collection("RealTime").document("RTLimeTrends")
        let document: DocumentSnapshot
        do {
            document = try await docRef.getDocument()
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let raw = document.data() else { return nil }
        return convertTimestamps(raw)
    }

    func isUserLoggedIn() async throws -> Bool {
        return Auth.auth().currentUser?.uid != nil
    }

    func getUserData() async throws -> [String : Any]? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        let docRef = db.collection("Users").document(uid)
        let document: DocumentSnapshot
        do {
            document = try await docRef.getDocument()
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let raw = document.data() else { return nil }
        return convertTimestamps(raw)
    }

    func getQuestions() async throws -> [String : Any]? {
        return SomLiMeTestBeta.data
    }

    func getBoardInfoData(boardName: String) async throws -> [String : Any]? {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            guard boardName != "" else{ return nil }
            let parsedBoardName = parseBoardName(boardName)
            let docRef = db.collection("BoardInfo").document(parsedBoardName)
            let document: DocumentSnapshot
            document = try await docRef.getDocument()
            guard let raw = document.data() else { return nil }
            return convertTimestamps(raw)
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardPostMetaList(boardName: String, startTime: String, counts: Int) async throws -> [[String : Any]]? {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            var colRef: Query
            guard boardName != "" else{ return nil }
            guard startTime != "" else{ return nil }
            guard counts != 0 else { return nil }
            let parsedBoardName = parseBoardName(boardName)
            if startTime == "NaN"{
                colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").order(by: "PublishedTime", descending: true).limit(to: counts)
            }else{
                colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").whereField("PublishedTime", isGreaterThanOrEqualTo: startTime).order(by: "PublishedTime", descending: true).limit(to: counts)
            }
            let documents: QuerySnapshot
            documents = try await colRef.getDocuments()
            var data: [[String: Any]] = []
            for document in documents.documents {
                var temp = convertTimestamps(document.data())
                temp["PostId"] = document.documentID
                data.append(temp)
            }
            return data
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardHotPostsList(boardName: String, startTime: String, counts: Int) async throws -> [String]? {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            var colRef: Query
            guard boardName != "" else{ return nil }
            guard startTime != "" else{ return nil }
            guard counts != 0 else { return nil }
            let parsedBoardName = parseBoardName(boardName)
            if startTime == "NaN"{
                colRef = db.collection("BoardHotPosts").document(parsedBoardName).collection("Posts").order(by: "PublishedTime", descending: true).limit(to: counts)
            }else{
                colRef = db.collection("BoardHotPosts").document(parsedBoardName).collection("Posts").whereField("PublishedTime", isGreaterThanOrEqualTo: startTime).order(by: "PublishedTime", descending: true).limit(to: counts)
            }
            let documents: QuerySnapshot
            documents = try await colRef.getDocuments()
            var data: [String] = []
            for document in documents.documents {
                data.append(document.documentID)
            }
            return data
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardPostMeta(boardName: String, postId: String) async throws -> [String : Any]? {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard boardName != "" else{ return nil }
        let parsedBoardName = parseBoardName(boardName)
        do {
            let docRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").document(postId)
            guard let raw = try await docRef.getDocument().data() else { return nil }
            return convertTimestamps(raw)
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardPostContent(boardName: String, postId: String) async throws -> [[String : Any]]? {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard boardName != "" else{ return nil }
        let parsedBoardName = parseBoardName(boardName)
        guard postId != "" else{ return nil }
        do {
            var data: [[String:Any]] = []
            let docRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").document(postId).collection("BoardPostContents")
            data.append(try await docRef.document("Paragraph").getDocument().data() ?? [:])
            data.append(try await docRef.document("Image").getDocument().data() ?? [:])
            data.append(try await docRef.document("Video").getDocument().data() ?? [:])
            data.append(try await docRef.document("Comments").getDocument().data() ?? [:])
            return data
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func createPost(boardName: String, postData: BoardPostContentData) async throws {
        guard boardName != "" else{ return }
        let parsedBoardName = parseBoardName(boardName)
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            let userName = try await getUserData()?["UserName"]
            let colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts")
            let postType = postData.boardPostImageURLs.isEmpty ? "text" : "image"
            let docRef = try await colRef.addDocument(data: [
                "BoardTap": postData.boardPostTap,
                "CommentsNumber": 0,
                "PostTitle": postData.boardPostTitle,
                "PostType": postType,
                "PublishedTime": FieldValue.serverTimestamp(),
                "ThumbnailURL": "",
                "UserId": postData.boardPostUserId,
                "UserName": userName ?? "",
                "Views": 0,
                "VoteUps": 0,
            ])
            try await docRef.collection("BoardPostContents").document("Image").setData([
                "URLs": postData.boardPostImageURLs
            ])
            try await docRef.collection("BoardPostContents").document("Paragraph").setData([
                "Text": postData.boardPostParagraph
            ])
            try await docRef.collection("BoardPostContents").document("Video").setData([
                "URLs": [String]()
            ])
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async throws -> Void {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do{
            let userData = try await getUserData()
            let userName = (userData?["UserName"] as? String) ?? ""
            let userId = Auth.auth().currentUser?.uid ?? ""
            let parsedBoardName = parseBoardName(boardName)
            let colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").document(postId).collection("BoardPostContents").document("Comments").collection("CommentList")
            _ = try await colRef.addDocument(data: [
                "Text": text,
                "Target": target,
                "UserName": userName,
                "UserId": userId,
                "PostId": postId,
                "PublishedTime": Date.now.description,
                "IsRevised": "No",
            ])
        }catch{
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func getComments(boardName: String, postId: String) async throws -> [[String: Any]]? {
        guard let db = database else{
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard boardName != "" else { return nil }
        guard postId != "" else { return nil }
        let parsedBoardName = parseBoardName(boardName)
        do {
            let colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").document(postId).collection("BoardPostContents").document("Comments").collection("CommentList").order(by: "PublishedTime", descending: false)
            let documents = try await colRef.getDocuments()
            var data: [[String: Any]] = []
            for document in documents.documents {
                var temp = convertTimestamps(document.data())
                temp["PostId"] = postId
                data.append(temp)
            }
            return data
        }catch{
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func updateUser(userInfo: [String: Any]) async throws -> Void {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard let user = Auth.auth().currentUser else{
            throw UserLoginFailures.LoginFailed
        }
        let docRef = db.collection("Users").document(user.uid)
        try await docRef.setData(userInfo, merge: true)
    }

    func uploadImage(data: Data, path: String) async throws -> String {
        let storageRef = Storage.storage().reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    func deleteUser() async throws {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            throw UserLoginFailures.LoginFailed
        }
        do {
            try await db.collection("Users").document(uid).delete()
        } catch {
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func voteUpPost(boardName: String, postId: String) async throws {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard boardName != "", postId != "" else { return }
        let parsedBoardName = parseBoardName(boardName)
        let docRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").document(postId)
        do {
            try await db.runTransaction { transaction, errorPointer in
                let snapshot: DocumentSnapshot
                do {
                    snapshot = try transaction.getDocument(docRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
                let currentVotes = (snapshot.data()?["VoteUps"] as? Int) ?? 0
                transaction.updateData(["VoteUps": currentVotes + 1], forDocument: docRef)
                return nil
            }
        } catch {
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func createReport(boardName: String, postId: String, reason: String, detail: String) async throws {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        let userId = Auth.auth().currentUser?.uid ?? ""
        do {
            _ = try await db.collection("Reports").addDocument(data: [
                "BoardName": boardName,
                "PostId": postId,
                "Reason": reason,
                "Detail": detail,
                "ReporterId": userId,
                "ReportedTime": Date.now.description,
                "Status": "pending"
            ])
        } catch {
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func getUserPosts(userId: String) async throws -> [[String: Any]]? {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard userId != "" else { return nil }
        do {
            let boardList = Array(SomeLiMePTTypeDesc.typeDetail.keys)
            var allPosts: [[String: Any]] = []
            for board in boardList {
                let colRef = db.collection("BoardInfo").document(board).collection("Posts")
                    .whereField("UserId", isEqualTo: userId)
                    .order(by: "PublishedTime", descending: true)
                    .limit(to: 20)
                let documents = try await colRef.getDocuments()
                for document in documents.documents {
                    var temp = convertTimestamps(document.data())
                    temp["PostId"] = document.documentID
                    temp["BoardName"] = board
                    allPosts.append(temp)
                }
            }
            return allPosts
        } catch {
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getUserComments(userId: String) async throws -> [[String: Any]]? {
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard userId != "" else { return nil }
        do {
            let boardList = Array(SomeLiMePTTypeDesc.typeDetail.keys)
            var allComments: [[String: Any]] = []
            for board in boardList {
                let postsRef = db.collection("BoardInfo").document(board).collection("Posts").limit(to: 50)
                let posts = try await postsRef.getDocuments()
                for post in posts.documents {
                    let commentsRef = post.reference.collection("BoardPostContents").document("Comments").collection("CommentList")
                        .whereField("UserId", isEqualTo: userId)
                        .order(by: "PublishedTime", descending: true)
                        .limit(to: 10)
                    let comments = try await commentsRef.getDocuments()
                    for comment in comments.documents {
                        var temp = convertTimestamps(comment.data())
                        temp["BoardName"] = board
                        temp["PostId"] = post.documentID
                        allComments.append(temp)
                    }
                }
            }
            return allComments
        } catch {
            throw DataSourceFailures.CouldNotFindDocument
        }
    }
}
