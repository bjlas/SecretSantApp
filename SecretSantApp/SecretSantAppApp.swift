
//
//  SecretSantAppApp.swift
//  SecretSantApp
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct SecretSantAppApp: App {
    var body: some Scene {
        WindowGroup {
            GroupListView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .preferredColorScheme(.light)
        }
        // Todo se guarda en local con SwiftData
        .modelContainer(for: [
            Group.self,
            Person.self,
            Draw.self,
            Gift.self
        ])
    }
}
