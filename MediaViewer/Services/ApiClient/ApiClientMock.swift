import Foundation

// MARK: - ApiClientMock

final class ApiClientMock: ApiClient {
    
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

    var signInWithThrowableError: Error?
    var signInWithCallsCount = 0
    var signInWithCalled: Bool {
        signInWithCallsCount > 0
    }
    var signInWithReceivedCode: String?
    var signInWithReceivedInvocations: [String] = []
    var signInWithClosure: ((String) throws -> Void)?

    func signIn(with code: String) throws {
        if let error = signInWithThrowableError {
            throw error
        }
        signInWithCallsCount += 1
        signInWithReceivedCode = code
        signInWithReceivedInvocations.append(code)
        try signInWithClosure?(code)
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
    
   // MARK: - get<A: Decodable>

    var getPathParamsThrowableError: Error?
    var getPathParamsCallsCount = 0
    var getPathParamsCalled: Bool {
        getPathParamsCallsCount > 0
    }
    var getPathParamsReceivedArguments: (path: String, params: [String: Any])?
    var getPathParamsReceivedInvocations: [(path: String, params: [String: Any])] = []
    var getPathParamsReturnValue: Any!
    var getPathParamsClosure: ((String, [String: Any]) throws -> Any)?

    func get<A: Decodable>(path: String, params: [String: Any]) throws -> A {
        if let error = getPathParamsThrowableError {
            throw error
        }
        getPathParamsCallsCount += 1
        getPathParamsReceivedArguments = (path: path, params: params)
        getPathParamsReceivedInvocations.append((path: path, params: params))
        return try getPathParamsClosure.map({ try $0(path, params) as! A }) ?? getPathParamsReturnValue as! A
    }
    
   // MARK: - post<A: Decodable, B: Encodable>

    var postPathBodyThrowableError: Error?
    var postPathBodyCallsCount = 0
    var postPathBodyCalled: Bool {
        postPathBodyCallsCount > 0
    }
    var postPathBodyReceivedArguments: (path: String, body: Any?)?
    var postPathBodyReceivedInvocations: [(path: String, body: Any?)] = []
    var postPathBodyReturnValue: Any!
    var postPathBodyClosure: ((String, Any?) throws -> Any)?

    func post<A: Decodable, B: Encodable>(path: String, body: B?) throws -> A {
        if let error = postPathBodyThrowableError {
            throw error
        }
        postPathBodyCallsCount += 1
        postPathBodyReceivedArguments = (path: path, body: body)
        postPathBodyReceivedInvocations.append((path: path, body: body))
        return try postPathBodyClosure.map({ try $0(path, body) as! A }) ?? postPathBodyReturnValue as! A
    }
    
   // MARK: - content<B: Encodable>

    var contentPathBodyThrowableError: Error?
    var contentPathBodyCallsCount = 0
    var contentPathBodyCalled: Bool {
        contentPathBodyCallsCount > 0
    }
    var contentPathBodyReceivedArguments: (path: String, body: Any?)?
    var contentPathBodyReceivedInvocations: [(path: String, body: Any?)] = []
    var contentPathBodyReturnValue: Data!
    var contentPathBodyClosure: ((String, Any?) throws -> Data)?

    func content<B: Encodable>(path: String, body: B?) throws -> Data {
        if let error = contentPathBodyThrowableError {
            throw error
        }
        contentPathBodyCallsCount += 1
        contentPathBodyReceivedArguments = (path: path, body: body)
        contentPathBodyReceivedInvocations.append((path: path, body: body))
        return try contentPathBodyClosure.map({ try $0(path, body) }) ?? contentPathBodyReturnValue
    }
    
   // MARK: - contentDownload<B: Encodable>

    var contentDownloadPathBodyStoreUrlThrowableError: Error?
    var contentDownloadPathBodyStoreUrlCallsCount = 0
    var contentDownloadPathBodyStoreUrlCalled: Bool {
        contentDownloadPathBodyStoreUrlCallsCount > 0
    }
    var contentDownloadPathBodyStoreUrlReceivedArguments: (path: String, body: Any?, storeUrl: (URL) -> URL?)?
    var contentDownloadPathBodyStoreUrlReceivedInvocations: [(path: String, body: Any?, storeUrl: (URL) -> URL?)] = []
    var contentDownloadPathBodyStoreUrlReturnValue: URL?
    var contentDownloadPathBodyStoreUrlClosure: ((String, Any?, @escaping (URL) -> URL?) throws -> URL?)?

    func contentDownload<B: Encodable>(path: String, body: B?, storeUrl: @escaping (URL) -> URL?) throws -> URL? {
        if let error = contentDownloadPathBodyStoreUrlThrowableError {
            throw error
        }
        contentDownloadPathBodyStoreUrlCallsCount += 1
        contentDownloadPathBodyStoreUrlReceivedArguments = (path: path, body: body, storeUrl: storeUrl)
        contentDownloadPathBodyStoreUrlReceivedInvocations.append((path: path, body: body, storeUrl: storeUrl))
        return try contentDownloadPathBodyStoreUrlClosure.map({ try $0(path, body, storeUrl) }) ?? contentDownloadPathBodyStoreUrlReturnValue
    }
}
