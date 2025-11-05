//
//  SessionUC.swift
//  PushAuthentication
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import Foundation
import Combine

protocol SessionUC {
    func fetchSession() -> AnyPublisher<String, Error>
}

// MARK: - Success Mock

struct SessionUCSuccessMock: SessionUC {
    func fetchSession() -> AnyPublisher<String, Error> {
        Just("mock_session_success")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Failure Mock

struct SessionUCFailureMock: SessionUC {
    func fetchSession() -> AnyPublisher<String, Error> {
        Fail(error: NSError(domain: "SessionUC", code: -1001, userInfo: [
            NSLocalizedDescriptionKey: "Failed to fetch session"
        ])).eraseToAnyPublisher()
    }
}
