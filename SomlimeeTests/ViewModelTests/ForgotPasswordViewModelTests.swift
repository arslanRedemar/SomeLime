@testable import Somlimee
import XCTest

final class ForgotPasswordViewModelTests: XCTestCase {
    private var mockAuthRepo: MockAuthRepository!
    private var sut: ForgotPasswordViewModelImpl!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        sut = ForgotPasswordViewModelImpl(authRepo: mockAuthRepo)
    }

    func testSendPasswordResetSuccess() async {
        await sut.sendPasswordReset(email: "test@example.com")
        XCTAssertNotNil(sut.successMessage)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuthRepo.sendPasswordResetCallCount, 1)
        XCTAssertEqual(mockAuthRepo.lastPasswordResetEmail, "test@example.com")
    }

    func testSendPasswordResetFailure() async {
        mockAuthRepo.sendPasswordResetError = PasswordResetFailures.sendResetEmailFailed
        await sut.sendPasswordReset(email: "test@example.com")
        XCTAssertNil(sut.successMessage)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
}
