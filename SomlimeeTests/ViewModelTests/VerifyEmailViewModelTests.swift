@testable import Somlimee
import XCTest

final class VerifyEmailViewModelTests: XCTestCase {
    private var mockAuthRepo: MockAuthRepository!
    private var sut: VerifyEmailViewModelImpl!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        sut = VerifyEmailViewModelImpl(authRepo: mockAuthRepo)
    }

    func testCheckVerificationStatusWhenVerified() async {
        mockAuthRepo.isEmailVerified = true
        await sut.checkVerificationStatus()
        XCTAssertTrue(sut.isVerified)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testCheckVerificationStatusWhenNotVerified() async {
        mockAuthRepo.isEmailVerified = false
        await sut.checkVerificationStatus()
        XCTAssertFalse(sut.isVerified)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testCheckVerificationStatusOnError() async {
        mockAuthRepo.reloadCurrentUserError = NSError(domain: "test", code: 1)
        await sut.checkVerificationStatus()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testResendVerificationSuccess() async {
        await sut.resendVerification()
        XCTAssertNotNil(sut.successMessage)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockAuthRepo.sendEmailVerificationCallCount, 1)
    }

    func testResendVerificationFailure() async {
        mockAuthRepo.sendEmailVerificationError = NSError(domain: "test", code: 1)
        await sut.resendVerification()
        XCTAssertNil(sut.successMessage)
        XCTAssertNotNil(sut.errorMessage)
    }
}
