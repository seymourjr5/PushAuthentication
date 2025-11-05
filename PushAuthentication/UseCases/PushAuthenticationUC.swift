//
//  PushAuthenticationUC.swift
//  PushAuthentication
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import Foundation
import Combine

protocol PushAuthenticationUC {
    func getRegistrationStatus(session: String) -> AnyPublisher<RegistrationStatus, Error>
    func register(with uuid: String, session: String, token: String) -> AnyPublisher<Bool, Error>
    func deRegister(with uuid: String) -> AnyPublisher<Bool, Error>
}

// MARK: - Success Mock

struct PushAuthenticationUCSuccessMock: PushAuthenticationUC {
    func getRegistrationStatus(session: String) -> AnyPublisher<RegistrationStatus, Error> {
        Just(.register)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func register(with uuid: String, session: String, token: String) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deRegister(with uuid: String) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Failure Mock

struct PushAuthenticationUCFailureMock: PushAuthenticationUC {
    func getRegistrationStatus(session: String) -> AnyPublisher<RegistrationStatus, Error> {
        Fail(error: NSError(domain: "PushAuth", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Failed to fetch status"
        ])).eraseToAnyPublisher()
    }

    func register(with uuid: String, session: String, token: String) -> AnyPublisher<Bool, Error> {
        Fail(error: NSError(domain: "PushAuth", code: -2, userInfo: [
            NSLocalizedDescriptionKey: "Registration failed"
        ])).eraseToAnyPublisher()
    }

    func deRegister(with uuid: String) -> AnyPublisher<Bool, Error> {
        Fail(error: NSError(domain: "PushAuth", code: -3, userInfo: [
            NSLocalizedDescriptionKey: "Deregistration failed"
        ])).eraseToAnyPublisher()
    }
}

// MARK: - Another Device Mock

struct PushAuthenticationUCAnotherDeviceMock: PushAuthenticationUC {
    func getRegistrationStatus(session: String) -> AnyPublisher<RegistrationStatus, Error> {
        Just(.anotherDevice)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func register(with uuid: String, session: String, token: String) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deRegister(with uuid: String) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
