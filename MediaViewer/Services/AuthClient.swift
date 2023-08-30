import Dependencies
import Foundation
import KeychainAccess

protocol AuthClient {
    var redirectUri: String { get }
    func checkAppConfiguration() throws
    func oauthURL() -> URL

    func isAuthorized() -> Bool
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
        guard appEnv.clientId != "empty-client-id" else {
            throw ApiError.invalidAppConfig
        }
    }

    func oauthURL() -> URL {
        var components = URLComponents(string: appEnv.oauthUrl)!

        components.queryItems = [
            URLQueryItem(name: "client_id", value: appEnv.clientId),
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

// MARK: - AuthClientMock

final class AuthClientMock: AuthClient {
    
   // MARK: - redirectUri

    var redirectUri: String {
        get { underlyingRedirectUri }
        set(value) { underlyingRedirectUri = value }
    }
    private var underlyingRedirectUri: String!
    
   // MARK: - checkAppConfiguration

    var checkAppConfigurationThrowableError: Error?
    var checkAppConfigurationCallsCount = 0
    var checkAppConfigurationCalled: Bool {
        checkAppConfigurationCallsCount > 0
    }
    var checkAppConfigurationClosure: (() throws -> Void)?

    func checkAppConfiguration() throws {
        if let error = checkAppConfigurationThrowableError {
            throw error
        }
        checkAppConfigurationCallsCount += 1
        try checkAppConfigurationClosure?()
    }
    
   // MARK: - oauthURL

    var oauthURLCallsCount = 0
    var oauthURLCalled: Bool {
        oauthURLCallsCount > 0
    }
    var oauthURLReturnValue: URL!
    var oauthURLClosure: (() -> URL)?

    func oauthURL() -> URL {
        oauthURLCallsCount += 1
        return oauthURLClosure.map({ $0() }) ?? oauthURLReturnValue
    }
    
   // MARK: - isAuthorized

    var isAuthorizedCallsCount = 0
    var isAuthorizedCalled: Bool {
        isAuthorizedCallsCount > 0
    }
    var isAuthorizedReturnValue: Bool!
    var isAuthorizedClosure: (() -> Bool)?

    func isAuthorized() -> Bool {
        isAuthorizedCallsCount += 1
        return isAuthorizedClosure.map({ $0() }) ?? isAuthorizedReturnValue
    }
    
   // MARK: - signIn

    var signInThrowableError: Error?
    var signInCallsCount = 0
    var signInCalled: Bool {
        signInCallsCount > 0
    }
    var signInReceivedAuthCode: String?
    var signInReceivedInvocations: [String] = []
    var signInClosure: ((String) throws -> Void)?

    func signIn(_ authCode: String) throws {
        if let error = signInThrowableError {
            throw error
        }
        signInCallsCount += 1
        signInReceivedAuthCode = authCode
        signInReceivedInvocations.append(authCode)
        try signInClosure?(authCode)
    }
    
   // MARK: - logout

    var logoutCallsCount = 0
    var logoutCalled: Bool {
        logoutCallsCount > 0
    }
    var logoutClosure: (() -> Void)?

    func logout() {
        logoutCallsCount += 1
        logoutClosure?()
    }
}
