//
//  GoogleAuthManager.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 21/11/2026.
//


import SwiftUI
import GoogleSignIn
import UIKit
import Combine

@MainActor
final class GoogleAuthManager: ObservableObject {

    @Published var email: String?
    @Published var isLoading = false
    @Published private(set) var isRestoringSession = true
    @Published var errorMessage: String?
    @Published var hasGmailSendPermission = false
    private let gmailSendScope =
        "https://www.googleapis.com/auth/gmail.send"
    private var restorationWaiters: [CheckedContinuation<Void, Never>] = []
    
    var isConnected: Bool {
        email != nil
    }

    init() {
        restoreSession()
    }

    func restoreSession() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isRestoringSession = false
                let waiters = self.restorationWaiters
                self.restorationWaiters.removeAll()
                waiters.forEach { $0.resume() }

                if let user {
                    self.email = user.profile?.email
                    self.hasGmailSendPermission =
                        user.grantedScopes?.contains(self.gmailSendScope) ?? false
                } else if let error {
                    // -4 means there is no previous sign-in in the keychain.
                    // This is the normal signed-out state, not an app error.
                    if (error as NSError).code == -4 {
                        self.email = nil
                        self.hasGmailSendPermission = false
                    } else {
                        print("No se pudo restaurar Google Sign-In: \(error.localizedDescription)")
                    }
                } else {
                    self.email = nil
                    self.hasGmailSendPermission = false
                }
            }
        }
    }

    func waitForSessionRestoration() async {
        guard isRestoringSession else { return }
        await withCheckedContinuation { continuation in
            restorationWaiters.append(continuation)
        }
    }

    var canSendWithGmail: Bool {
        GIDSignIn.sharedInstance.currentUser?.grantedScopes?.contains(gmailSendScope) ?? false
    }

    func signIn() {
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: \.isKeyWindow)?
            .rootViewController else {
                errorMessage = String(localized: "settings.auth.could_not_open_sign_in")
                return
            }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        ) { [weak self] result, error in

            Task { @MainActor [weak self] in
                guard let self else { return }

                self.isLoading = false

                if let error {
                    if (error as NSError).code == -8 {
                        self.hasGmailSendPermission = true
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard let user = result?.user else {
                    self.errorMessage = String(localized: "settings.auth.could_not_sign_in")
                    return
                }

                self.email = user.profile?.email
                self.hasGmailSendPermission =
                    user.grantedScopes?.contains(self.gmailSendScope) ?? false
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        email = nil
        hasGmailSendPermission = false
    }
    
    
    func requestGmailPermission() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            errorMessage = String(localized: "settings.auth.connect_first")
            return
        }
        
        if user.grantedScopes?.contains(gmailSendScope) == true {
            hasGmailSendPermission = true
            errorMessage = nil
            return
        }

        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: \.isKeyWindow)?
            .rootViewController else {
                errorMessage = String(localized: "settings.auth.could_not_open_authorization")
                return
        }

        isLoading = true
        errorMessage = nil

        user.addScopes(
            [gmailSendScope],
            presenting: rootViewController
        ) { [weak self] result, error in

            Task { @MainActor [weak self] in
                guard let self else { return }

                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let updatedUser = result?.user else {
                    self.errorMessage = String(localized: "settings.auth.authorization_missing")
                    return
                }

                self.hasGmailSendPermission =
                    updatedUser.grantedScopes?.contains(self.gmailSendScope) ?? false
            }
        }
    }

    func getGmailAccessToken() async throws -> String {

        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw GmailAuthError.notConnected
        }

        guard user.grantedScopes?.contains(gmailSendScope) == true else {
            throw GmailAuthError.permissionNotGranted
        }

        let refreshedUser = try await user.refreshTokensIfNeeded()

        return refreshedUser.accessToken.tokenString
    }

}

enum GmailAuthError: LocalizedError {

    case notConnected
    case permissionNotGranted

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return String(localized: "settings.auth.not_connected")

        case .permissionNotGranted:
            return String(localized: "settings.auth.permission_missing")
        }
    }
}
