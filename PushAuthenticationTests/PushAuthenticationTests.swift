//
//  PushAuthenticationTests.swift
//  PushAuthenticationTests
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import XCTest
import Combine

@testable import PushAuthentication

final class PushRegistrationViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables = []
        super.tearDown()
    }

    // MARK: - Load Registration Status

    func testLoadRegistrationStatusSuccess() {
        // GIVEN a ViewModel with success mocks
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCSuccessMock(),
            sessionUC: SessionUCSuccessMock(),
            vendorUC: VendorUCSuccessMock(),
            notificationSettingsUC: NotificationSettingsUCSuccessMock(),
            uuid: "uuid-123",
            scheduler: DispatchQueue(label: "test"),
            delayInterval: .seconds(0)
        )

        let expectation = XCTestExpectation(description: "Load registration status success")

        // WHEN loading registration status
        sut.$isRegistered
            .dropFirst()
            .sink { isRegistered in
                // THEN it should be registered
                XCTAssertTrue(isRegistered)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadRegistrationStatus()

        wait(for: [expectation], timeout: 5.0)
    }

    func testLoadRegistrationStatusFailure() {
        // GIVEN a ViewModel with failure mocks
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCFailureMock(),
            sessionUC: SessionUCFailureMock(),
            vendorUC: VendorUCFailureMock(),
            notificationSettingsUC: NotificationSettingsUCSuccessMock(),
            uuid: "uuid-123",
            scheduler: DispatchQueue(label: "test"),
            delayInterval: .seconds(0)
        )

        let expectation = XCTestExpectation(description: "Load registration status failure")

        // WHEN loadRegistrationStatus is called
        sut.loadRegistrationStatus()

        // WHEN loading registration status
        sut.$errorMessage
            .dropFirst()
            .sink { error in
                // THEN errorMessage should not be nil
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testLoadRegistrationStatusFailure_anotherDeviceError() {
        // GIVEN a ViewModel with failure mocks
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCAnotherDeviceMock(),
            sessionUC: SessionUCSuccessMock(),
            vendorUC: VendorUCSuccessMock(),
            notificationSettingsUC: NotificationSettingsUCSuccessMock(),
            uuid: "uuid-123",
            scheduler: DispatchQueue(label: "test"),
            delayInterval: .seconds(0)
        )

        let expectation = XCTestExpectation(description: "Load registration status failure")

        // WHEN loadRegistrationStatus is called
        sut.loadRegistrationStatus()

        // WHEN loading registration status
        sut.$errorMessage
            .dropFirst()
            .sink { error in
                // THEN
                XCTAssertNotNil(error)
                XCTAssertEqual(error, "Registered on another device")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Registration

    func testRegisterSuccess() {
        // GIVEN a ViewModel with success mocks
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCSuccessMock(),
            sessionUC: SessionUCSuccessMock(),
            vendorUC: VendorUCSuccessMock(),
            notificationSettingsUC: NotificationSettingsUCSuccessMock(),
            uuid: "uuid-123",
            scheduler: DispatchQueue(label: "test"),
            delayInterval: .seconds(0)
        )

        let expectation = XCTestExpectation(description: "Register success")

        // WHEN toggleRegistration
        sut.toggleRegistration(to: true)

        // WHEN toggling registration to true
        sut.$isRegistered
            .dropFirst()
            .sink { isRegistered in
                // THEN isRegistered should be true
                XCTAssertTrue(isRegistered)
                XCTAssertNil(sut.errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testRegisterFailure() {
        // GIVEN a ViewModel with push token denied
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCSuccessMock(),
            sessionUC: SessionUCSuccessMock(),
            vendorUC: VendorUCSuccessMock(),
            notificationSettingsUC: NotificationSettingsUCDeniedMock(),
            uuid: "uuid-123",
            scheduler: DispatchQueue(label: "test"),
            delayInterval: .seconds(0)
        )

        let expectation = XCTestExpectation(description: "Register failure due to push denied")

        // WHEN toggleRegistration is called
        sut.toggleRegistration(to: true)

        // WHEN toggling registration to true
        sut.$errorMessage
            .dropFirst()
            .sink { error in
                // THEN errorMessage should indicate push denied
                XCTAssertEqual(error, "Notifications not allowed")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - De-registration

    func testDeRegisterSuccess() {
        // GIVEN a ViewModel with success mocks
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCSuccessMock(),
            sessionUC: SessionUCSuccessMock(),
            vendorUC: VendorUCSuccessMock(),
            notificationSettingsUC: NotificationSettingsUCSuccessMock(),
            uuid: "uuid-123"
        )

        let expectation = XCTestExpectation(description: "De-register success")

        // WHEN toggleRegistration is called
        sut.toggleRegistration(to: false)

        // WHEN toggling registration to false
        sut.$isRegistered
            .dropFirst()
            .sink { isRegistered in
                // THEN isRegistered should be false
                XCTAssertFalse(isRegistered)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDeRegisterFailure() {
        // GIVEN a ViewModel with failure mocks
        let sut = PushRegistrationViewModel(
            pushUC: PushAuthenticationUCFailureMock(),
            sessionUC: SessionUCSuccessMock(),
            vendorUC: VendorUCFailureMock(),
            notificationSettingsUC: NotificationSettingsUCSuccessMock(),
            uuid: "uuid-123",
            scheduler: DispatchQueue(label: "test"),
            delayInterval: .seconds(0)
        )

        let expectation = XCTestExpectation(description: "De-register failure")

        // WHEN toggling registration to false (triggering de-register)
        sut.toggleRegistration(to: false)

        // WHEN observing errorMessage
        sut.$errorMessage
            .dropFirst()
            .sink { error in
                // THEN errorMessage should not be nil
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
}

