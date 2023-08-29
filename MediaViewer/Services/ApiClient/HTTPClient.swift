import Dependencies
import Foundation

protocol HTTPClient {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {}

// MARK: - DI

extension DependencyValues {
    var httpClient: any HTTPClient {
        get { self[HTTPClientKey.self] }
        set { self[HTTPClientKey.self] = newValue }
    }
}

enum HTTPClientKey: DependencyKey {
    static var liveValue: any HTTPClient {
        URLSession.shared
    }
}
