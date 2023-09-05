import Foundation

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
        return oauthURLClosure.map { $0() } ?? oauthURLReturnValue
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
        return isAuthorizedClosure.map { $0() } ?? isAuthorizedReturnValue
    }

    // MARK: - isLogoutAllowed

    var isLogoutAllowedCallsCount = 0
    var isLogoutAllowedCalled: Bool {
        isLogoutAllowedCallsCount > 0
    }

    var isLogoutAllowedReturnValue: Bool = false
    var isLogoutAllowedClosure: (() -> Bool)?

    func isLogoutAllowed() -> Bool {
        isLogoutAllowedCallsCount += 1
        return isLogoutAllowedClosure.map { $0() } ?? isLogoutAllowedReturnValue
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
