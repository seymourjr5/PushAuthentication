//
//  PushRegistrationViewModel.swift
//  PushAuthentication
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import SwiftUI
import Combine

// MARK: - PushRegistrationViewModel

final class PushRegistrationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var isRegistered = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Use Cases

    private let pushUC: PushAuthenticationUC
    private let sessionUC: SessionUC
    private let vendorUC: VendorUC
    private let notificationSettingsUC: NotificationSettingsUC

    // MARK: - Private Properties

    private let uuid: String
    private let scheduler: DispatchQueue
    private let delayInterval: DispatchQueue.SchedulerTimeType.Stride
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialiser

    init(
        pushUC: PushAuthenticationUC = PushAuthenticationUCSuccessMock(),
        sessionUC: SessionUC = SessionUCSuccessMock(),
        vendorUC: VendorUC = VendorUCSuccessMock(),
        notificationSettingsUC: NotificationSettingsUC = NotificationSettingsUCSuccessMock(),
        uuid: String = "SomeUUID",
        scheduler: DispatchQueue = .main,
        delayInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(3)
    ) {
        self.pushUC = pushUC
        self.sessionUC = sessionUC
        self.vendorUC = vendorUC
        self.notificationSettingsUC = notificationSettingsUC
        self.uuid = uuid
        self.scheduler = scheduler
        self.delayInterval = delayInterval
    }

    // MARK: - Load combined registration status

    func loadRegistrationStatus() {
        isLoading = true
        errorMessage = nil

        sessionUC.fetchSession()
            .delay(for: delayInterval, scheduler: scheduler)
            .flatMap { [weak self] session -> AnyPublisher<(RegistrationStatus, RegistrationStatus), Error> in
                guard let self else {
                    return Fail(error: URLError(.cancelled)).eraseToAnyPublisher()
                }
                let pushStatus = self.pushUC.getRegistrationStatus(session: session)
                let vendorStatus = self.vendorUC.checkRegistrationStatusPublisher(uuid: self.uuid)
                return Publishers.CombineLatest(pushStatus, vendorStatus).eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] pushStatus, vendorStatus in
                guard let self else { return }
                if pushStatus == .anotherDevice {
                    self.errorMessage = "Registered on another device"
                    self.isRegistered = false
                    return
                }
                self.isRegistered = (pushStatus == .register && vendorStatus == .register)
            }
            .store(in: &cancellables)
    }

    // MARK: - Toggle

    func toggleRegistration(to newValue: Bool) {
        newValue ? register() : deRegister()
    }

    // MARK: - Registration

    private func register() {
        isLoading = true
        errorMessage = nil

        getPushTokenPublisher()
            .flatMap { [weak self] token -> AnyPublisher<(Bool, Bool), Error> in
                guard let self else {
                    return Fail(error: URLError(.cancelled)).eraseToAnyPublisher()
                }

                return self.sessionUC.fetchSession()
                    .delay(for: delayInterval, scheduler: self.scheduler)
                    .flatMap { session -> AnyPublisher<(Bool, Bool), Error> in
                        let pushReg = self.pushUC.register(with: self.uuid, session: session, token: token)
                        let vendorReg = self.vendorUC.registerUser(with: self.uuid)
                        return Publishers.Zip(pushReg, vendorReg).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.isRegistered = false
                }
            } receiveValue: { [weak self] pushSuccess, vendorSuccess in
                let success = pushSuccess && vendorSuccess
                self?.errorMessage = success ? nil : "Failed to register device"
                self?.isRegistered = success
            }
            .store(in: &cancellables)
    }

    // MARK: - De-registration

    private func deRegister() {
        isLoading = true
        errorMessage = nil

        let pushDereg = pushUC.deRegister(with: uuid)
        let vendorDereg = vendorUC.deRegisterUser(with: uuid)

        Publishers.Zip(pushDereg, vendorDereg)
            .delay(for: delayInterval, scheduler: self.scheduler)
            .receive(on: scheduler)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] pushSuccess, vendorSuccess in
                let success = pushSuccess && vendorSuccess
                self?.errorMessage = success ? nil : "Failed to de-register device"
                self?.isRegistered = !success
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers

    private func getPushTokenPublisher() -> AnyPublisher<String, Error> {
        notificationSettingsUC
            .fetchAuthorizationStatus()
            .tryMap { status in
                guard status == .authorized else {
                    throw NSError(domain: "Push", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "Notifications not allowed"
                    ])
                }
                return "mock_push_token_123"
            }
            .eraseToAnyPublisher()
    }
}
