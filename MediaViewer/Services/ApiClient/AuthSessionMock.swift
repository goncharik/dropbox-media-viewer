import Foundation

// MARK: - AuthSessionProtocolMock

final class AuthSessionProtocolMock: AuthSessionProtocol {
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

    // MARK: - validToken

    var validTokenThrowableError: Error?
    var validTokenCallsCount = 0
    var validTokenCalled: Bool {
        validTokenCallsCount > 0
    }

    var validTokenReturnValue: AuthToken!
    var validTokenClosure: (() throws -> AuthToken)?

    func validToken() throws -> AuthToken {
        if let error = validTokenThrowableError {
            throw error
        }
        validTokenCallsCount += 1
        return try validTokenClosure.map { try $0() } ?? validTokenReturnValue
    }

    // MARK: - refreshToken

    var refreshTokenThrowableError: Error?
    var refreshTokenCallsCount = 0
    var refreshTokenCalled: Bool {
        refreshTokenCallsCount > 0
    }

    var refreshTokenReturnValue: AuthToken!
    var refreshTokenClosure: (() throws -> AuthToken)?

    @discardableResult
    func refreshToken() throws -> AuthToken {
        if let error = refreshTokenThrowableError {
            throw error
        }
        refreshTokenCallsCount += 1
        return try refreshTokenClosure.map { try $0() } ?? refreshTokenReturnValue
    }

    // MARK: - obtainToken

    var obtainTokenForThrowableError: Error?
    var obtainTokenForCallsCount = 0
    var obtainTokenForCalled: Bool {
        obtainTokenForCallsCount > 0
    }

    var obtainTokenForReceivedAuthorizationCode: String?
    var obtainTokenForReceivedInvocations: [String] = []
    var obtainTokenForReturnValue: AuthToken!
    var obtainTokenForClosure: ((String) throws -> AuthToken)?

    @discardableResult
    func obtainToken(for authorizationCode: String) throws -> AuthToken {
        if let error = obtainTokenForThrowableError {
            throw error
        }
        obtainTokenForCallsCount += 1
        obtainTokenForReceivedAuthorizationCode = authorizationCode
        obtainTokenForReceivedInvocations.append(authorizationCode)
        return try obtainTokenForClosure.map { try $0(authorizationCode) } ?? obtainTokenForReturnValue
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
