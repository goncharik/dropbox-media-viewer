import Dependencies
import Foundation

enum AuthError: Error {
    case missingToken
    case invalidToken
}

protocol AuthSessionProtocol {
    func isAuthorized() -> Bool
    func validToken() async throws -> String
    @discardableResult
    func refreshToken() async throws -> AuthToken
    @discardableResult
    func obtainToken(for authorizationCode: String) async throws -> AuthToken
    func logout() async
}

actor AuthSession: AuthSessionProtocol {
    private nonisolated let currentToken: Isolated<AuthToken?>

    private var refreshTask: Task<AuthToken, Error>?

    private let appEnv: AppEnv
    private let tokenStorage: TokenStorage
    private let httpClient: HTTPClient

    init(appEnv: AppEnv, tokenStorage: TokenStorage, httpClient: HTTPClient) {
        self.appEnv = appEnv
        self.tokenStorage = tokenStorage
        self.httpClient = httpClient
        let token = tokenStorage.load()
        currentToken = Isolated(token, didSet: { _, newValue in
            tokenStorage.save(newValue)
        })
    }

    nonisolated func isAuthorized() -> Bool {
        switch appEnv.appAuthType {
        case .oauth:
            return currentToken.value != nil
        case .accessToken:
            return true
        }
    }

    func validToken() async throws -> String {
        if case let .accessToken(token) = appEnv.appAuthType {
            return token
        }

        if let handle = refreshTask {
            return try await handle.value.accessToken
        }

        guard let token = currentToken.value else {
            throw AuthError.missingToken
        }

        if token.isValid {
            return token.accessToken
        }

        return try await refreshToken().accessToken
    }

    @discardableResult
    func refreshToken() async throws -> AuthToken {
        if let refreshTask {
            return try await refreshTask.value
        }

        guard let refreshToken = currentToken.value?.refreshToken else {
            throw AuthError.missingToken
        }

        let task = Task { () throws -> AuthToken in
            defer { refreshTask = nil }
            print("Refreshing token...")

            let tokenURL = URL(string: appEnv.baseUrl + "/oauth2/token")!
            var request = URLRequest(url: tokenURL)
            request.httpMethod = "POST"

            let bodyParameters = [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": appEnv.clientId ?? "",
                "client_secret": appEnv.clientSecret ?? "",
            ]
            request.httpBody = bodyParameters
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
                .data(using: .utf8)
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            do {
                var newToken: AuthToken = try await httpClient.model(for: request)
                // Add missing data for refresh token response:
                newToken.refreshToken = refreshToken
                newToken.createdAt = Date()
                newToken.uid = currentToken.value?.uid
                newToken.accountId = currentToken.value?.accountId

                currentToken.value = newToken
                return newToken
            } catch {
                print("Failed to refresh token: \(error)")
                throw AuthError.invalidToken
            }
        }

        refreshTask = task

        return try await task.value
    }

    @discardableResult
    func obtainToken(for authorizationCode: String) async throws -> AuthToken {
        let clientID = appEnv.clientId
        let clientSecret = appEnv.clientSecret
        let redirectURI = appEnv.defaultRedirectUri
        let tokenURL = URL(string: appEnv.baseUrl + "/oauth2/token")!

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"

        let bodyParameters: [String: String] = [
            "grant_type": "authorization_code",
            "code": authorizationCode,
            "redirect_uri": redirectURI,
            "client_id": clientID ?? "",
            "client_secret": clientSecret ?? "",
        ]

        let bodyData = bodyParameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var accessToken: AuthToken = try await httpClient.model(for: request)
        accessToken.createdAt = Date()
        currentToken.value = accessToken

        return accessToken
    }

    func logout() {
        currentToken.value = nil
    }
}

// MARK: - DI

extension DependencyValues {
    var authSession: AuthSession {
        get { self[AuthSession.self] }
        set { self[AuthSession.self] = newValue }
    }
}

extension AuthSession: DependencyKey {
    static var liveValue: AuthSession {
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.tokenStorage) var tokenStorage

        return AuthSession(
            appEnv: .live,
            tokenStorage: tokenStorage,
            httpClient: httpClient
        )
    }
}
