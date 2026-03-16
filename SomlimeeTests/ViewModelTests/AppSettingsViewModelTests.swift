//
//  AppSettingsViewModelTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class AppSettingsViewModelTests: XCTestCase {
    private var sut: AppSettingsViewModelImpl!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults for test isolation
        UserDefaults.standard.removeObject(forKey: "commentNotificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "darkModeEnabled")
        sut = AppSettingsViewModelImpl()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "commentNotificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "darkModeEnabled")
        sut = nil
        super.tearDown()
    }

    // MARK: - Default Values Tests

    func testDefaultValues() {
        XCTAssertTrue(sut.commentNotificationsEnabled)
        XCTAssertFalse(sut.darkModeEnabled)
    }

    // MARK: - Save and Load Tests

    func testSaveAndLoadCommentNotifications() {
        sut.commentNotificationsEnabled = false
        sut.saveSettings()

        let newVm = AppSettingsViewModelImpl()
        XCTAssertFalse(newVm.commentNotificationsEnabled)
    }

    func testSaveAndLoadDarkMode() {
        sut.darkModeEnabled = true
        sut.saveSettings()

        let newVm = AppSettingsViewModelImpl()
        XCTAssertTrue(newVm.darkModeEnabled)
    }

    func testSaveAndLoadBothSettings() {
        sut.commentNotificationsEnabled = false
        sut.darkModeEnabled = true
        sut.saveSettings()

        let newVm = AppSettingsViewModelImpl()
        XCTAssertFalse(newVm.commentNotificationsEnabled)
        XCTAssertTrue(newVm.darkModeEnabled)
    }

    // MARK: - Load Settings Tests

    func testLoadSettingsWithExistingData() {
        UserDefaults.standard.set(false, forKey: "commentNotificationsEnabled")
        UserDefaults.standard.set(true, forKey: "darkModeEnabled")

        let newVm = AppSettingsViewModelImpl()

        XCTAssertFalse(newVm.commentNotificationsEnabled)
        XCTAssertTrue(newVm.darkModeEnabled)
    }

    func testLoadSettingsWithNoExistingData() {
        let newVm = AppSettingsViewModelImpl()

        XCTAssertTrue(newVm.commentNotificationsEnabled)
        XCTAssertFalse(newVm.darkModeEnabled)
    }
}
