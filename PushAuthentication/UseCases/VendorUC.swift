//
//  VendorUC.swift
//  PushAuthentication
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import Foundation
import Combine

protocol VendorUC {
    func checkRegistrationStatusPublisher(uuid: String) -> AnyPublisher<RegistrationStatus, Error>
    func registerUser(with uuid: String) -> AnyPublisher<Bool, Error>
    func deRegisterUser(with uuid: String) -> AnyPublisher<Bool, Error>
}

// MARK: - Success Mock

struct VendorUCSuccessMock: VendorUC {
    func checkRegistrationStatusPublisher(uuid: String) -> AnyPublisher<RegistrationStatus, Error> {
        Just(.register).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func registerUser(with uuid: String) -> AnyPublisher<Bool, Error> {
        Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func deRegisterUser(with uuid: String) -> AnyPublisher<Bool, Error> {
        Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// MARK: - Failure Mock

struct VendorUCFailureMock: VendorUC {
    func checkRegistrationStatusPublisher(uuid: String) -> AnyPublisher<RegistrationStatus, Error> {
        Fail(error: NSError(domain: "VendorUC", code: -2001, userInfo: [
            NSLocalizedDescriptionKey: "Failed to fetch vendor status"
        ])).eraseToAnyPublisher()
    }

    func registerUser(with uuid: String) -> AnyPublisher<Bool, Error> {
        Fail(error: NSError(domain: "VendorUC", code: -2002, userInfo: [
            NSLocalizedDescriptionKey: "Vendor registration failed"
        ])).eraseToAnyPublisher()
    }

    func deRegisterUser(with uuid: String) -> AnyPublisher<Bool, Error> {
        Fail(error: NSError(domain: "VendorUC", code: -2003, userInfo: [
            NSLocalizedDescriptionKey: "Vendor deregistration failed"
        ])).eraseToAnyPublisher()
    }
}
