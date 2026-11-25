//
//  GmailService.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 21/11/2026.
//


import Foundation

@MainActor
final class GmailService {

    static let shared = GmailService()

    private init() {}

    func sendEmail(
        to recipient: String,
        subject: String,
        body: String,
        accessToken: String
    ) async throws {

        // Build an RFC 2822 MIME message. The complete message is base64url
        // encoded below for Gmail's API, so keep the MIME body as readable
        // UTF-8 instead of adding a second base64 layer.
        let encodedSubject = Data(subject.utf8).base64EncodedString()
        let crlf = "\r\n"
        let normalizedBody = body
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\n", with: crlf)
        let mimeMessage = [
            "To: \(recipient)",
            "Subject: =?UTF-8?B?\(encodedSubject)?=",
            "MIME-Version: 1.0",
            "Content-Type: text/plain; charset=UTF-8",
            "Content-Transfer-Encoding: 8bit",
            "",
            normalizedBody,
            ""
        ].joined(separator: crlf)

        // Codificación Base64URL
        let rawData = Data(mimeMessage.utf8)

        let rawMessage = rawData
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        // Preparar petición
        guard let url = URL(
            string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"
        ) else {
            throw GmailServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let payload: [String: String] = [
            "raw": rawMessage
        ]

        request.httpBody = try JSONSerialization.data(
            withJSONObject: payload
        )

        // Enviar correo
        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GmailServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let responseText = String(
                data: data,
                encoding: .utf8
            ) ?? String(localized: "settings.gmail.no_details")

            throw GmailServiceError.serverError(
                httpResponse.statusCode,
                responseText
            )
        }
    }

}

enum GmailServiceError: LocalizedError {

    case invalidURL
    case invalidResponse
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {

        case .invalidURL:
            return String(localized: "settings.gmail.invalid_url")

        case .invalidResponse:
            return String(localized: "settings.gmail.invalid_response")

        case .serverError(let code, let details):
            return localizedFormat(
                NSLocalizedString("settings.gmail.gmail_error", comment: ""),
                code,
                details
            )
        }
    }
}
