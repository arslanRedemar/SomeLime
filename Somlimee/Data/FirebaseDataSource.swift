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
import os


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
        Log.data.debug("getLimeTrendsData: start")
        guard let db = database else {
            Log.data.error("getLimeTrendsData: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        let docRef = db.collection("RealTime").document("RTLimeTrends")
        let document: DocumentSnapshot
        do {
            document = try await docRef.getDocument()
        }catch{
            Log.data.error("getLimeTrendsData: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let raw = document.data() else {
            Log.data.info("getLimeTrendsData: no data")
            return nil
        }
        Log.data.debug("getLimeTrendsData: success")
        return convertTimestamps(raw)
    }

    func isUserLoggedIn() async throws -> Bool {
        let result = Auth.auth().currentUser?.uid != nil
        Log.data.debug("isUserLoggedIn: \(result)")
        return result
    }

    func getUserData() async throws -> [String : Any]? {
        Log.data.debug("getUserData: start")
        guard let uid = Auth.auth().currentUser?.uid else {
            Log.data.info("getUserData: no current user")
            return nil
        }
        guard let db = database else{
            Log.data.error("getUserData: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        let docRef = db.collection("Users").document(uid)
        let document: DocumentSnapshot
        do {
            document = try await docRef.getDocument()
        }catch{
            Log.data.error("getUserData: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let raw = document.data() else {
            Log.data.info("getUserData: no data for uid=\(uid)")
            return nil
        }
        Log.data.debug("getUserData: success for uid=\(uid)")
        return convertTimestamps(raw)
    }

    func getQuestions() async throws -> [String : Any]? {
        return SomLiMeTestBeta.data
    }

    func getBoardInfoData(boardName: String) async throws -> [String : Any]? {
        Log.data.debug("getBoardInfoData: board=\(boardName)")
        guard let db = database else{
            Log.data.error("getBoardInfoData: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            guard boardName != "" else{
                Log.data.info("getBoardInfoData: empty boardName")
                return nil
            }
            let parsedBoardName = parseBoardName(boardName)
            let docRef = db.collection("BoardInfo").document(parsedBoardName)
            let document: DocumentSnapshot
            document = try await docRef.getDocument()
            guard let raw = document.data() else {
                Log.data.info("getBoardInfoData: no data for \(boardName)")
                return nil
            }
            Log.data.debug("getBoardInfoData: success for \(boardName)")
            return convertTimestamps(raw)
        }catch{
            Log.data.error("getBoardInfoData: failed for \(boardName) — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [[String : Any]]? {
        Log.data.debug("getBoardPostMetaList: board=\(boardName) startTime=\(startTime ?? "nil") counts=\(counts)")
        guard let db = database else{
            Log.data.error("getBoardPostMetaList: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            var colRef: Query
            guard boardName != "" else{ return nil }
            guard counts != 0 else { return nil }
            let parsedBoardName = parseBoardName(boardName)
            if let startTime, !startTime.isEmpty {
                colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").whereField("PublishedTime", isGreaterThanOrEqualTo: startTime).order(by: "PublishedTime", descending: true).limit(to: counts)
            } else {
                colRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").order(by: "PublishedTime", descending: true).limit(to: counts)
            }
            let documents: QuerySnapshot
            documents = try await colRef.getDocuments()
            var data: [[String: Any]] = []
            for document in documents.documents {
                var temp = convertTimestamps(document.data())
                temp["PostId"] = document.documentID
                data.append(temp)
            }
            Log.data.debug("getBoardPostMetaList: returned \(data.count) posts for \(boardName)")
            return data
        }catch{
            Log.data.error("getBoardPostMetaList: failed for \(boardName) — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [String]? {
        Log.data.debug("getBoardHotPostsList: board=\(boardName) counts=\(counts)")
        guard let db = database else{
            Log.data.error("getBoardHotPostsList: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        do {
            var colRef: Query
            guard boardName != "" else{ return nil }
            guard counts != 0 else { return nil }
            let parsedBoardName = parseBoardName(boardName)
            if let startTime, !startTime.isEmpty {
                colRef = db.collection("BoardHotPosts").document(parsedBoardName).collection("Posts").whereField("PublishedTime", isGreaterThanOrEqualTo: startTime).order(by: "PublishedTime", descending: true).limit(to: counts)
            } else {
                colRef = db.collection("BoardHotPosts").document(parsedBoardName).collection("Posts").order(by: "PublishedTime", descending: true).limit(to: counts)
            }
            let documents: QuerySnapshot
            documents = try await colRef.getDocuments()
            var data: [String] = []
            for document in documents.documents {
                data.append(document.documentID)
            }
            Log.data.debug("getBoardHotPostsList: returned \(data.count) IDs for \(boardName)")
            return data
        }catch{
            Log.data.error("getBoardHotPostsList: failed for \(boardName) — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardPostMeta(boardName: String, postId: String) async throws -> [String : Any]? {
        Log.data.debug("getBoardPostMeta: board=\(boardName) postId=\(postId)")
        guard let db = database else{
            Log.data.error("getBoardPostMeta: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard boardName != "" else{ return nil }
        let parsedBoardName = parseBoardName(boardName)
        do {
            let docRef = db.collection("BoardInfo").document(parsedBoardName).collection("Posts").document(postId)
            guard let raw = try await docRef.getDocument().data() else {
                Log.data.info("getBoardPostMeta: no data for \(postId)")
                return nil
            }
            Log.data.debug("getBoardPostMeta: success for \(postId)")
            return convertTimestamps(raw)
        }catch{
            Log.data.error("getBoardPostMeta: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getBoardPostContent(boardName: String, postId: String) async throws -> [[String : Any]]? {
        Log.data.debug("getBoardPostContent: board=\(boardName) postId=\(postId)")
        guard let db = database else{
            Log.data.error("getBoardPostContent: database not found")
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
            Log.data.debug("getBoardPostContent: success for postId=\(postId)")
            return data
        }catch{
            Log.data.error("getBoardPostContent: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func createPost(boardName: String, postData: BoardPostContentData) async throws {
        Log.data.info("createPost: board=\(boardName) title=\(postData.boardPostTitle)")
        guard boardName != "" else{ return }
        let parsedBoardName = parseBoardName(boardName)
        guard let db = database else{
            Log.data.error("createPost: database not found")
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
            Log.data.info("createPost: success for board=\(boardName)")
        }catch{
            Log.data.error("createPost: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async throws -> Void {
        Log.data.info("writeComment: board=\(boardName) postId=\(postId)")
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
            Log.data.info("writeComment: success for postId=\(postId)")
        }catch{
            Log.data.error("writeComment: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func getComments(boardName: String, postId: String) async throws -> [[String: Any]]? {
        Log.data.debug("getComments: board=\(boardName) postId=\(postId)")
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
            Log.data.debug("getComments: returned \(data.count) comments for postId=\(postId)")
            return data
        }catch{
            Log.data.error("getComments: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func updateUser(userInfo: [String: Any]) async throws -> Void {
        Log.data.info("updateUser: keys=\(Array(userInfo.keys))")
        guard let db = database else {
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard let user = Auth.auth().currentUser else{
            throw UserLoginFailures.LoginFailed
        }
        let docRef = db.collection("Users").document(user.uid)
        try await docRef.setData(userInfo, merge: true)
        Log.data.info("updateUser: success for uid=\(user.uid)")
    }

    func uploadImage(data: Data, path: String) async throws -> String {
        Log.data.info("uploadImage: path=\(path) size=\(data.count) bytes")
        let storageRef = Storage.storage().reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        Log.data.info("uploadImage: success url=\(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }

    func deleteUser() async throws {
        Log.data.info("deleteUser: start")
        guard let db = database else {
            Log.data.error("deleteUser: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            Log.data.error("deleteUser: no current user")
            throw UserLoginFailures.LoginFailed
        }
        do {
            try await db.collection("Users").document(uid).delete()
            Log.data.info("deleteUser: success for uid=\(uid)")
        } catch {
            Log.data.error("deleteUser: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func voteUpPost(boardName: String, postId: String) async throws {
        Log.data.info("voteUpPost: board=\(boardName) postId=\(postId)")
        guard let db = database else {
            Log.data.error("voteUpPost: database not found")
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
            Log.data.info("voteUpPost: success for postId=\(postId)")
        } catch {
            Log.data.error("voteUpPost: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func createReport(boardName: String, postId: String, reason: String, detail: String) async throws {
        Log.data.info("createReport: board=\(boardName) postId=\(postId) reason=\(reason)")
        guard let db = database else {
            Log.data.error("createReport: database not found")
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
            Log.data.info("createReport: success")
        } catch {
            Log.data.error("createReport: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotUpdateData
        }
    }

    func getUserPosts(userId: String) async throws -> [[String: Any]]? {
        Log.data.debug("getUserPosts: userId=\(userId)")
        guard let db = database else {
            Log.data.error("getUserPosts: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard userId != "" else { return nil }
        do {
            let boardList = BoardRegistry.allBoards
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
            Log.data.debug("getUserPosts: returned \(allPosts.count) posts")
            return allPosts
        } catch {
            Log.data.error("getUserPosts: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getUserComments(userId: String) async throws -> [[String: Any]]? {
        Log.data.debug("getUserComments: userId=\(userId)")
        guard let db = database else {
            Log.data.error("getUserComments: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard userId != "" else { return nil }
        do {
            let boardList = BoardRegistry.allBoards
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
            Log.data.debug("getUserComments: returned \(allComments.count) comments")
            return allComments
        } catch {
            Log.data.error("getUserComments: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func getNotifications(limit: Int) async throws -> [[String: Any]]? {
        Log.data.debug("getNotifications: limit=\(limit)")
        guard let db = database else {
            Log.data.error("getNotifications: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        do {
            let colRef = db.collection("Notifications").document(uid).collection("items")
                .order(by: "timestamp", descending: true)
                .limit(to: limit)
            let documents = try await colRef.getDocuments()
            var data: [[String: Any]] = []
            for document in documents.documents {
                var temp = convertTimestamps(document.data())
                temp["id"] = document.documentID
                data.append(temp)
            }
            Log.data.debug("getNotifications: returned \(data.count) notifications")
            return data
        } catch {
            Log.data.error("getNotifications: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotFindDocument
        }
    }

    func markNotificationRead(notificationId: String) async throws {
        Log.data.info("markNotificationRead: id=\(notificationId)")
        guard let db = database else {
            Log.data.error("markNotificationRead: database not found")
            throw DataSourceFailures.CouldNotFindRemoteDataBase
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            Log.data.error("markNotificationRead: no current user")
            throw UserLoginFailures.LoginFailed
        }
        do {
            let docRef = db.collection("Notifications").document(uid).collection("items").document(notificationId)
            try await docRef.updateData(["isRead": true])
            Log.data.info("markNotificationRead: success for id=\(notificationId)")
        } catch {
            Log.data.error("markNotificationRead: failed — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotUpdateData
        }
    }
}
