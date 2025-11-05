//
//  PushRegistrationView.swift
//  PushAuthentication
//
//  Created by Seymour Rodrigues on 04/11/2025.
//

import SwiftUI

// MARK: - PushRegistrationView

struct PushRegistrationView: View {

    // MARK: - ViewModel

    @StateObject private var viewModel: PushRegistrationViewModel

    // MARK: - Initialiser

    init(
        pushUC: PushAuthenticationUC = PushAuthenticationUCSuccessMock(),
        sessionUC: SessionUC = SessionUCSuccessMock(),
        vendorUC: VendorUC = VendorUCSuccessMock(),
        notificationSettingsUC: NotificationSettingsUC = NotificationSettingsUCSuccessMock()
    ) {
        let wrappedViewModel = PushRegistrationViewModel(
            pushUC: pushUC,
            sessionUC: sessionUC,
            vendorUC: vendorUC,
            notificationSettingsUC: notificationSettingsUC
        )

        self._viewModel = StateObject(wrappedValue: wrappedViewModel)
    }

    // MARK: - View body

    var body: some View {
        VStack(spacing: 24) {
            Text("Push Registration")
                .font(.title2)
                .bold()

            Spacer()

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Toggle(isOn: Binding(
                    get: { viewModel.isRegistered },
                    set: { viewModel.toggleRegistration(to: $0) }
                )) {
                    Text("Register")
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.horizontal)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadRegistrationStatus()
        }
    }
}

// MARK: - Previews

#Preview("Success") {
    PushRegistrationView(
        pushUC: PushAuthenticationUCSuccessMock(),
        sessionUC: SessionUCSuccessMock(),
        vendorUC: VendorUCSuccessMock(),
        notificationSettingsUC: NotificationSettingsUCSuccessMock()
    )
}

#Preview("Failed to fetch Push authentication status") {
    PushRegistrationView(
        pushUC: PushAuthenticationUCFailureMock(),
        sessionUC: SessionUCSuccessMock(),
        vendorUC: VendorUCSuccessMock(),
        notificationSettingsUC: NotificationSettingsUCSuccessMock()
    )
}

#Preview("Failed to fetch vendor status") {
    PushRegistrationView(
        pushUC: PushAuthenticationUCSuccessMock(),
        sessionUC: SessionUCSuccessMock(),
        vendorUC: VendorUCFailureMock(),
        notificationSettingsUC: NotificationSettingsUCSuccessMock()
    )
}

#Preview("Another Device") {
    PushRegistrationView(
        pushUC: PushAuthenticationUCAnotherDeviceMock(),
        sessionUC: SessionUCSuccessMock(),
        vendorUC: VendorUCSuccessMock(),
        notificationSettingsUC: NotificationSettingsUCSuccessMock()
    )
}
