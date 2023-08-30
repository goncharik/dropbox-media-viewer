import Dependencies
import Foundation

struct ApiError: Error, Decodable {
    let error: String
    let errorDescription: String

    static var invalidResponse: Self {
        .init(error: "invalid_response", errorDescription: "Invalid response")
    }
}

protocol ApiClient {
    func isAuthorized() -> Bool
    func signIn(with code: String) async throws
    func logout() async
    func get<A: Decodable>(path: String, params: [String: Any]) async throws -> A
    func post<A: Decodable, B: Encodable>(path: String, body: B?) async throws -> A
    func content<B: Encodable>(path: String, body: B?) async throws -> Data
    func contentDownload<B: Encodable>(path: String, body: B?, storeUrl: @escaping (URL) -> URL?) async throws -> URL?
}

final class ApiClientImpl: ApiClient {
    private let appEnv: AppEnv
    private let httpClient: HTTPClient
    private let authSession: AuthSession

    init(appEnv: AppEnv, httpClient: HTTPClient, authSession: AuthSession) {
        self.appEnv = appEnv
        self.httpClient = httpClient
        self.authSession = authSession
    }

    func isAuthorized() -> Bool {
        authSession.isAuthorized()
    }

    func signIn(with code: String) async throws {
        try await authSession.obtainToken(for: code)
    }

    func logout() async {
        await authSession.logout()
    }

    func get<A: Decodable>(path: String, params: [String: Any]) async throws -> A {
        let url = URL(string: "\(appEnv.baseUrl)\(path)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data = try await runAuthorized(request)
        return try apiDecode(from: data)
    }

    func post<A: Decodable>(path: String, body: (some Encodable)?) async throws -> A {
        let url = URL(string: "\(appEnv.baseUrl)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder.default.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data = try await runAuthorized(request)
        return try apiDecode(from: data)
    }

    func content<B: Encodable>(path: String, body: B?) async throws -> Data {
        let url = URL(string: "\(appEnv.contentUrl)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let file = try body?.toJsonString() ?? "{}"
        request.addValue(file, forHTTPHeaderField: "Dropbox-API-Arg")

        return try await runAuthorized(request)
    }

    func contentDownload<B: Encodable>(path: String, body: B?, storeUrl: @escaping (URL) -> URL?) async throws -> URL? {
        let url = URL(string: "\(appEnv.contentUrl)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let token = try await authSession.validToken()
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")

        let file = try body?.toJsonString() ?? "{}"
        request.addValue(file, forHTTPHeaderField: "Dropbox-API-Arg")

        print("Request:", request.debugDescription)
        return try await withCheckedThrowingContinuation { continuation in
            let task = httpClient.downloadTask(with: request) { url, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: ApiError.invalidResponse)
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    continuation.resume(throwing: ApiError.invalidResponse)
                    return
                }

                guard let url = url else {
                    continuation.resume(throwing: ApiError.invalidResponse)
                    return
                }

                let cachedUrl = storeUrl(url)

                continuation.resume(returning: cachedUrl)
            }
            task.resume()
        }
    }

    // MARK: - Private helpers

    private func runAuthorized(_ request: URLRequest, allowRetry: Bool = true) async throws -> Data {
        var request = request
        let token = try await authSession.validToken()
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        print("Request:", request.debugDescription)
        let (data, urlResponse) = try await httpClient.data(for: request)

        // check the http status code and refresh + retry if we received 401 Unauthorized
        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if allowRetry {
                try await authSession.refreshToken()
                return try await runAuthorized(request, allowRetry: false)
            }

            throw AuthError.invalidToken
        }
        return data
    }
}

// MARK: - DI

extension DependencyValues {
    var apiClient: any ApiClient {
        get { self[ApiClientKey.self] }
        set { self[ApiClientKey.self] = newValue }
    }
}

enum ApiClientKey: DependencyKey {
    static var liveValue: any ApiClient {
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.tokenStorage) var tokenStorage

        let appEnv = AppEnv.live
        let authSession = AuthSession(
            appEnv: appEnv,
            tokenStorage: tokenStorage,
            httpClient: httpClient
        )
        return ApiClientImpl(
            appEnv: appEnv,
            httpClient: httpClient,
            authSession: authSession
        )
    }
}

// MARK: - Extensions and helper functions

extension HTTPClient {
    func model<A: Decodable>(for request: URLRequest) async throws -> A {
        let (data, _) = try await data(for: request)
        return try apiDecode(from: data)
    }
}

private func apiDecode<A: Decodable>(from data: Data) throws -> A {
    do {
        return try JSONDecoder.default.decode(A.self, from: data)
    } catch let decodingError {
        let apiError: Error
        do {
            apiError = try JSONDecoder.default.decode(ApiError.self, from: data)
        } catch {
            throw decodingError
        }
        throw apiError
    }
}
