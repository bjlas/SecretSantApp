import SwiftUI
import GoogleSignInSwift


struct SettingsView: View {
    @StateObject private var googleAuth = GoogleAuthManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.personScreenBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        VStack(spacing: 10) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(Color.accent)
                                .frame(width: 76, height: 76)
                                .background(Color.accentSoft, in: Circle())

                            Text("settings.title")
                                .font(.title2.bold())
                                .foregroundStyle(.primary)

                            Text("settings.account_description")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                        FormSectionCard {
                            VStack(alignment: .leading, spacing: 16) {
                                FormSectionHeading(
                                    title: "settings.google_account",
                                    subtitle: "settings.gmail.connect_hint"
                                )

                    if googleAuth.isConnected {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("settings.google_connected")
                                    .font(.headline)
                                Text(googleAuth.email ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("settings.disconnect", role: .destructive) {
                                googleAuth.signOut()
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Color.personFieldBackground, in: Capsule())
                        }

                        if googleAuth.hasGmailSendPermission {
                            Label("settings.gmail.authorized", systemImage: "envelope.badge.fill")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.green)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.personFieldBackground, in: RoundedRectangle(cornerRadius: 16))
                        } else {
                            Text("settings.gmail.permission_hint")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button {
                                googleAuth.requestGmailPermission()
                            } label: {
                                Label("settings.authorize_email_sending", systemImage: "envelope")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.accent)
                            .disabled(googleAuth.isLoading)
                        }
                    } else {
                        Text("settings.gmail.connect_account_hint")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        GoogleSignInButton {
                            googleAuth.signIn()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .disabled(googleAuth.isLoading || googleAuth.isRestoringSession)
                    }

                    if googleAuth.isLoading || googleAuth.isRestoringSession {
                        ProgressView(LocalizedStringKey(googleAuth.isRestoringSession ? "settings.checking_session" : "settings.connecting_to_google"))
                            .font(.caption)
                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                

            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.accent)
                    }
                    .accessibilityLabel("common.back")
                }
            }
            .alert(
                "settings.could_not_complete_the_operation",
                isPresented: Binding(
                    get: { googleAuth.errorMessage != nil },
                    set: { if !$0 { googleAuth.errorMessage = nil } }
                )
            ) {
                Button("common.ok", role: .cancel) { googleAuth.errorMessage = nil }
            } message: {
                Text(LocalizedStringKey(googleAuth.errorMessage ?? "settings.unknown_error"))
            }
        }
    }
}

#Preview {
    SettingsView()
}


