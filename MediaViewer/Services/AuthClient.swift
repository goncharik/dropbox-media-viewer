import Dependencies
import Foundation

protocol AuthClient {
    var redirectUri: String { get }
    func checkAppConfiguration() throws
    func oauthURL() -> URL

    func isAuthorized() -> Bool
    func isLogoutAllowed() -> Bool
    func signIn(_ authCode: String) async throws
    func logout() async
}

final class AuthClientImpl: AuthClient {
    var redirectUri: String { appEnv.defaultRedirectUri }

    private let appEnv: AppEnv
    private let apiClient: ApiClient

    init(
        appEnv: AppEnv,
        apiClient: ApiClient
    ) {
        self.appEnv = appEnv
        self.apiClient = apiClient
    }

    func checkAppConfiguration() throws {
        switch appEnv.appAuthType {
        case let .oauth(clientId, _):
            guard clientId != "empty-client-id" else {
                throw ApiError.invalidAppConfig
            }
        case let .accessToken(token):
            guard token != "empty-access-token" else {
                throw ApiError.invalidAppConfig
            }
        }

    }

    func oauthURL() -> URL {
        var components = URLComponents(string: appEnv.oauthUrl)!

        components.queryItems = [
            URLQueryItem(name: "client_id", value: appEnv.clientId ?? ""),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: appEnv.defaultRedirectUri),
            URLQueryItem(name: "token_access_type", value: "offline"),
            URLQueryItem(name: "force_reapprove", value: "true"),
            URLQueryItem(name: "disable_signup", value: "true"),
        ]

        return components.url!
    }

    func isAuthorized() -> Bool {
        apiClient.isAuthorized()
    }

    func isLogoutAllowed() -> Bool {
        switch appEnv.appAuthType {
        case .oauth:
            return true
        case .accessToken:
            return false
        }
    }

    func signIn(_ authCode: String) async throws {
        try await apiClient.signIn(with: authCode)
    }

    func logout() async {
        await apiClient.logout()
    }
}

// MARK: - DI

extension DependencyValues {
    var authClient: any AuthClient {
        get { self[AuthClientKey.self] }
        set { self[AuthClientKey.self] = newValue }
    }
}

enum AuthClientKey: DependencyKey {
    static var liveValue: any AuthClient {
        @Dependency(\.apiClient) var apiClient

        return AuthClientImpl(
            appEnv: AppEnv.live,
            apiClient: apiClient
        )
    }
}
