//
//  FirestoreEmulatorTestBase.swift
//  SomlimeeTests
//
//  Integration test base class that connects to the Firestore & Auth emulators.
//

@testable import Somlimee
import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirestoreEmulatorTestBase: XCTestCase {

    // MARK: - Static setup (once per test run)

    private static var isFirebaseConfigured = false
    static let projectID = "somlime-47d80"
    static let testEmail = "integration-test@somlimee.test"
    static let testPassword = "TestPassword123!"

    /// The real FirebaseDataSource under test, connected to the emulator.
    var dataSource: FirebaseDataSource!

    /// Firestore instance (emulator-connected).
    var db: Firestore!

    /// UID of the signed-in test user.
    var testUID: String!

    // MARK: - Lifecycle

    override func setUp() async throws {
        try await super.setUp()

        Self.configureFirebaseOnce()

        db = Firestore.firestore()
        dataSource = FirebaseDataSource()

        // Ensure a test user exists and is signed in.
        try await signInTestUser()
        testUID = Auth.auth().currentUser!.uid
    }

    override func tearDown() async throws {
        // Clear Firestore data via emulator REST API.
        await clearFirestoreData()
        // Delete all Auth users via emulator REST API.
        await clearAuthUsers()
        // Sign out.
        try? Auth.auth().signOut()

        dataSource = nil
        db = nil
        testUID = nil

        try await super.tearDown()
    }

    // MARK: - Firebase Configuration

    private static func configureFirebaseOnce() {
        guard !isFirebaseConfigured else { return }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Point Firestore to emulator
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isSSLEnabled = false
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings

        // Point Auth to emulator
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)

        isFirebaseConfigured = true
    }

    // MARK: - Auth Helpers

    private func signInTestUser() async throws {
        do {
            try await Auth.auth().signIn(
                withEmail: Self.testEmail,
                password: Self.testPassword
            )
        } catch {
            // User doesn't exist yet — create it.
            try await Auth.auth().createUser(
                withEmail: Self.testEmail,
                password: Self.testPassword
            )
        }
    }

    /// Creates a second user and signs in as that user. Returns the UID.
    /// Useful for cross-user security rule tests.
    @discardableResult
    func signInAsOtherUser(
        email: String = "other-user@somlimee.test",
        password: String = "OtherPass123!"
    ) async throws -> String {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            try await Auth.auth().createUser(withEmail: email, password: password)
        }
        return Auth.auth().currentUser!.uid
    }

    /// Signs back in as the primary test user.
    func signInAsPrimaryUser() async throws {
        try await Auth.auth().signIn(
            withEmail: Self.testEmail,
            password: Self.testPassword
        )
    }

    // MARK: - Data Seeding Helpers

    /// Seeds a top-level document. Creates intermediate collections as needed.
    func seedDocument(
        collection: String,
        document: String,
        data: [String: Any]
    ) async throws {
        try await db.collection(collection).document(document).setData(data)
    }

    /// Seeds a document at an arbitrary path (e.g. "BoardInfo/SDR/Posts/post1").
    /// The path must have an even number of segments (collection/document pairs).
    func seedDocumentAtPath(_ path: String, data: [String: Any]) async throws {
        let segments = path.split(separator: "/").map(String.init)
        precondition(segments.count >= 2 && segments.count.isMultiple(of: 2),
                     "Path must have even segments: \(path)")

        var ref: DocumentReference = db.collection(segments[0]).document(segments[1])
        var i = 2
        while i < segments.count {
            ref = ref.collection(segments[i]).document(segments[i + 1])
            i += 2
        }
        try await ref.setData(data)
    }

    /// Reads back a document by full path and returns its data.
    func readDocument(atPath path: String) async throws -> [String: Any]? {
        let segments = path.split(separator: "/").map(String.init)
        precondition(segments.count >= 2 && segments.count.isMultiple(of: 2))

        var ref: DocumentReference = db.collection(segments[0]).document(segments[1])
        var i = 2
        while i < segments.count {
            ref = ref.collection(segments[i]).document(segments[i + 1])
            i += 2
        }
        let snapshot = try await ref.getDocument()
        return snapshot.data()
    }

    // MARK: - Emulator Cleanup (REST API)

    private func clearFirestoreData() async {
        let urlString = "http://localhost:8080/emulator/v1/projects/\(Self.projectID)/databases/(default)/documents"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try? await URLSession.shared.data(for: request)
    }

    private func clearAuthUsers() async {
        let urlString = "http://localhost:9099/emulator/v1/projects/\(Self.projectID)/accounts"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try? await URLSession.shared.data(for: request)
    }
}
