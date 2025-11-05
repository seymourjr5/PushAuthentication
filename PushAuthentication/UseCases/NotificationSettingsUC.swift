//
//  NotificationSettingsUC.swift
//  PushAuthentication
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import Combine
import UserNotifications

enum NotificationAuthorizationStatus {
    case authorized
    case denied
}

protocol NotificationSettingsUC {
    func fetchAuthorizationStatus() -> AnyPublisher<NotificationAuthorizationStatus, Never>
}

struct NotificationSettingsUCImpl: NotificationSettingsUC {
    func fetchAuthorizationStatus() -> AnyPublisher<NotificationAuthorizationStatus, Never> {
        Future { promise in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let status: NotificationAuthorizationStatus = (settings.authorizationStatus == .authorized) ? .authorized : .denied
                promise(.success(status))
            }
        }
        .eraseToAnyPublisher()
    }
}

struct NotificationSettingsUCSuccessMock: NotificationSettingsUC {
    func fetchAuthorizationStatus() -> AnyPublisher<NotificationAuthorizationStatus, Never> {
        Just(.authorized).eraseToAnyPublisher()
    }
}

struct NotificationSettingsUCDeniedMock: NotificationSettingsUC {
    func fetchAuthorizationStatus() -> AnyPublisher<NotificationAuthorizationStatus, Never> {
        Just(.denied).eraseToAnyPublisher()
    }
}
